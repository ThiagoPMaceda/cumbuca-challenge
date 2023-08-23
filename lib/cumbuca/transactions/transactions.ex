defmodule Cumbuca.Transactions do
  alias Cumbuca.Transactions.Chargeback
  alias Cumbuca.Transactions.Schemas.Transaction
  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.Schemas.{Account, User}
  alias Cumbuca.Repo
  alias Ecto.Multi

  import Ecto.Query, warn: false

  def get_transaction_by_id(id), do: Repo.get(Transaction, id)

  defdelegate chargeback(params), to: Chargeback, as: :process

  def get_transactions_by_interval(start_date, end_date, user_id) do
    %User{account_id: account_id} = Accounts.get_user_by_id(user_id)

    start_utc_usec_string = "T00:00:00.00000Z"
    end_utc_usec_string = "T23:59:59.999999Z"

    start_date_utc_string = start_date <> start_utc_usec_string
    end_date_utc_string = end_date <> end_utc_usec_string

    transactions =
      Transaction
      |> where([t], t.sender_id == ^account_id)
      |> where([t], t.inserted_at >= ^start_date_utc_string)
      |> where([t], t.inserted_at <= ^end_date_utc_string)
      |> order_by([t], asc: t.inserted_at)
      |> Repo.all()

    {:ok, transactions}
  end

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
    |> Multi.run(:retrieved_accounts, &retrieved_accounts(&1, &2, recipient_id, sender_id))
    |> Multi.run(:check_sender_funds, &check_sender_funds(&1, &2, amount))
    |> Multi.update_all(:recipient_update_query, recipient_update_query, [])
    |> Multi.run(:check_recipient_update_query, &check_recipient_update_query(&1, &2))
    |> Multi.update_all(:sender_update_query, sender_update_query, [])
    |> Multi.run(:check_sender_update_query, &check_sender_update_query(&1, &2))
    |> Multi.insert(:insert_transaction, %Transaction{
      sender_id: sender_id,
      recipient_id: recipient_id,
      amount: amount
    })
    |> Repo.transaction()
    |> handle_multi()
  end

  defp retrieved_accounts(_repo, _changes, recipient_id, sender_id) do
    id_list = [sender_id, recipient_id]
    Accounts.get_sender_and_recipient_accounts(id_list, sender_id, recipient_id)
  end

  defp check_sender_funds(_repo, %{retrieved_accounts: [sender_account, _]}, amount) do
    if sender_account.balance - amount >= 0,
      do: {:ok, nil},
      else: {:error, :insufficient_funds}
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
