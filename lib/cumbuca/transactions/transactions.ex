defmodule Cumbuca.Transactions do
  alias Cumbuca.Transactions.Schemas.Transaction
  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.Schemas.Account
  alias Cumbuca.Repo
  alias Ecto.Multi
  import Ecto.Query, warn: false

  def create_transaction(%{sender_id: sender_id, recipient_id: recipient_id, amount: amount}) do
    sender_update_query =
      from Account,
        where: [id: ^sender_id],
        update: [inc: [balance: ^(-amount)]]

    recipient_update_query =
      from Account,
        where: [id: ^recipient_id],
        update: [inc: [balance: ^(+amount)]]

    Multi.new()
    |> Multi.run(
      :retrieved_accounts,
      fn _repo, _multi ->
        {:ok, Accounts.get_by_ids([sender_id, recipient_id])}
      end
    )
    |> Multi.run(:check_sender_funds, &check_sender_funds(&1, &2, amount))
    |> Multi.update_all(:recipient_update_query, recipient_update_query, [])
    |> Multi.run(
      :check_recipient_update_query,
      &check_recipient_update_query(&1, &2, recipient_update_query)
    )
    |> Multi.update_all(:sender_update_query, sender_update_query, [])
    |> Multi.run(
      :check_sender_update_query,
      &check_sender_update_query(&1, &2, sender_update_query)
    )
    |> Multi.insert(:insert_transaction, %Transaction{
      sender_id: sender_id,
      recipient_id: recipient_id,
      amount: amount
    })
    |> Repo.transaction()
    |> handle_multi()
  end

  defp check_sender_funds(_repo, %{retrieved_accounts: [sender_account, _]}, amount) do
    if sender_account.balance >= amount,
      do: {:ok, nil},
      else: {:error, :insufficient_funds}
  end

  defp check_sender_funds(_repo, %{retrieved_accounts: list}, _amount) when length(list) == 0 do
    {:error, :account_not_found}
  end

  defp check_recipient_update_query(
         _repo,
         %{recipient_update_query: {1, _}},
         _recipient_update_query
       ) do
    {:ok, nil}
  end

  defp check_recipient_update_query(
         _repo,
         %{recipient_update_query: {_, _}},
         recipient_update_query
       ) do
    {:error, {:failed_transfer, recipient_update_query}}
  end

  defp check_sender_update_query(
         _repo,
         %{sender_update_query: {1, _}},
         _sender_update_query
       ) do
    {:ok, nil}
  end

  defp check_sender_update_query(_repo, %{sender_update_query: {_, _}}, sender_update_query) do
    {:error, {:failed_transfer, sender_update_query}}
  end

  defp handle_multi({:ok, %{insert_transaction: transaction}}), do: {:ok, transaction}
  defp handle_multi({:error, _id, error_or_changeset, _multi}), do: {:error, error_or_changeset}
end
