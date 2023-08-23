defmodule Cumbuca.Transactions.Chargeback do
  import Ecto.Query, warn: false

  alias Ecto.{Changeset, Multi}
  alias Cumbuca.{Accounts, Repo, Transactions}
  alias Cumbuca.Accounts.Schemas.Account
  alias Cumbuca.Transactions.Schemas.Transaction

  def process(%{transaction_id: transaction_id}) do
    Multi.new()
    |> Multi.run(:transaction, fn _r, _c -> get_transaction_by_id(transaction_id) end)
    |> Multi.run(:accounts, fn _repo,
                               %{transaction: %{sender_id: sender_id, recipient_id: recipient_id}} ->
      id_list = [sender_id, recipient_id]
      Accounts.get_sender_and_recipient_accounts(id_list, sender_id, recipient_id)
    end)
    |> Multi.run(:check_recipient_funds, &check_recipient_funds(&1, &2))
    |> Multi.update_all(:recipient_update_query, &update_query(&1, :recipient), [])
    |> Multi.run(:check_recipient_update_query, &check_recipient_update_query(&1, &2))
    |> Multi.update_all(:sender_update_query, &update_query(&1, :sender), [])
    |> Multi.run(:check_sender_update_query, &check_sender_update_query(&1, &2))
    |> Multi.update(:update_transaction, fn %{transaction: transaction} ->
      Changeset.change(transaction, chargeback: true, chargeback_date: DateTime.utc_now())
    end)
    |> Repo.transaction()
    |> handle_multi()
  end

  defp get_transaction_by_id(transaction_id) do
    case Transactions.get_transaction_by_id(transaction_id) do
      nil ->
        {:error, :transaction_not_found}

      %Transaction{chargeback: true} ->
        {:error, :chargeback_already_processed}

      %Transaction{} = transaction ->
        {:ok, transaction}
    end
  end

  defp check_recipient_funds(_repo, %{
         accounts: [_, recipient],
         transaction: transaction
       }) do
    if recipient.balance - transaction.amount >= 0,
      do: {:ok, nil},
      else: {:error, :insufficient_funds_for_chargeback}
  end

  defp update_query(%{accounts: [sender, _], transaction: transaction}, :sender) do
    from Account,
      where: [id: ^sender.id],
      update: [inc: [balance: ^(+transaction.amount)]]
  end

  defp update_query(%{accounts: [_, recipient], transaction: transaction}, :recipient) do
    from Account,
      where: [id: ^recipient.id],
      update: [inc: [balance: ^(-transaction.amount)]]
  end

  defp check_recipient_update_query(
         _repo,
         %{recipient_update_query: {1, _}}
       ) do
    {:ok, nil}
  end

  defp check_recipient_update_query(
         _repo,
         %{recipient_update_query: {_, _}}
       ) do
    {:error, :failed_transfer}
  end

  defp check_sender_update_query(
         _repo,
         %{sender_update_query: {1, _}}
       ) do
    {:ok, nil}
  end

  defp check_sender_update_query(_repo, %{sender_update_query: {_, _}}) do
    {:error, :failed_transfer}
  end

  defp handle_multi({:ok, %{insert_transaction: transaction}}), do: {:ok, transaction}
  defp handle_multi({:ok, %{update_transaction: transaction}}), do: {:ok, transaction}
  defp handle_multi({:error, _id, error_or_changeset, _multi}), do: {:error, error_or_changeset}
end
