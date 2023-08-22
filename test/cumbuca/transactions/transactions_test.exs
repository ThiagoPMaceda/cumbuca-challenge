defmodule Cumbuca.TransactionsTest do
  use Cumbuca.DataCase, async: true

  alias Cumbuca.Accounts.Schemas.Account
  alias Cumbuca.Transactions.Schemas.Transaction
  alias Cumbuca.Transactions

  setup do
    account_one = insert!(:account, balance: 200_00)
    account_two = insert!(:account, balance: 200_00)

    {:ok, %{account_one: account_one, account_two: account_two}}
  end

  describe "create_transaction/1" do
    test "creates a transaction with valid data", %{
      account_one: account_one,
      account_two: account_two
    } do
      attrs = %{sender_id: account_one.id, recipient_id: account_two.id, amount: 10_00}

      assert {:ok, %Transaction{sender_id: sender_id, recipient_id: recipient_id}} =
               Transactions.create_transaction(attrs)

      sender = Repo.get(Account, sender_id)
      recipient = Repo.get(Account, recipient_id)

      assert sender.balance == 19_000
      assert recipient.balance == 21_000
    end

    test "calculations are correct with multiple transactions", %{
      account_one: account_one,
      account_two: account_two
    } do
      transaction_one = %{sender_id: account_one.id, recipient_id: account_two.id, amount: 50_00}
      transaction_two = %{sender_id: account_one.id, recipient_id: account_two.id, amount: 37_50}

      transaction_three = %{
        sender_id: account_one.id,
        recipient_id: account_two.id,
        amount: 20_00
      }

      transaction_four = %{
        sender_id: account_two.id,
        recipient_id: account_one.id,
        amount: 100_00
      }

      transaction_five = %{sender_id: account_one.id, recipient_id: account_two.id, amount: 10_00}

      assert {:ok, %Transaction{sender_id: account_one_id, recipient_id: account_two_id}} =
               Transactions.create_transaction(transaction_one)

      assert {:ok, _transaction_two} = Transactions.create_transaction(transaction_two)
      assert {:ok, _transaction_three} = Transactions.create_transaction(transaction_three)
      assert {:ok, _transaction_four} = Transactions.create_transaction(transaction_four)
      assert {:ok, _transaction_five} = Transactions.create_transaction(transaction_five)

      sender = Repo.get(Account, account_one_id)
      recipient = Repo.get(Account, account_two_id)

      assert sender.balance == 18_250
      assert recipient.balance == 21_750
    end

    test "retuns error if any of the accounts are not found", %{} do
      attrs = %{
        sender_id: Ecto.UUID.generate(),
        recipient_id: Ecto.UUID.generate(),
        amount: 10_00
      }

      assert {:error, :account_not_found} == Transactions.create_transaction(attrs)
    end

    test "retuns error if sender account does not have sufficient funds", %{
      account_one: account_one,
      account_two: account_two
    } do
      attrs = %{sender_id: account_one.id, recipient_id: account_two.id, amount: 90_000_00}

      assert {:error, :insufficient_funds} = Transactions.create_transaction(attrs)
    end
  end

  describe "get_transactions_by_interval/3" do
    test "return ordered transactions in specified interval" do
      %{id: user_id, account_id: account_id} = insert!(:user_with_account)
      start_date = "2023-08-01T00:00:00.911400Z"
      end_date = "2023-08-30T00:00:00.911400Z"

      transaction_in_range_one =
        insert!(:transaction, sender_id: account_id, inserted_at: ~U[2023-08-01T00:00:00.911400Z])

      transaction_in_range_two =
        insert!(:transaction, sender_id: account_id, inserted_at: ~U[2023-08-15T00:00:00.911400Z])

      transaction_in_range_three =
        insert!(:transaction, sender_id: account_id, inserted_at: ~U[2023-08-27T00:00:00.911400Z])

      transaction_in_range_four =
        insert!(:transaction, sender_id: account_id, inserted_at: ~U[2023-08-30T00:00:00.911400Z])

      _transaction_out_of_range_one =
        insert!(:transaction, sender_id: account_id, inserted_at: ~U[2023-10-01T00:00:00.911400Z])

      _transaction_out_of_range_two =
        insert!(:transaction, sender_id: account_id, inserted_at: ~U[2023-07-30T00:00:00.911400Z])

      expected_ordered_transactions = [
        transaction_in_range_one,
        transaction_in_range_two,
        transaction_in_range_three,
        transaction_in_range_four
      ]

      assert {:ok, expected_ordered_transactions} ==
               Transactions.get_transactions_by_interval(start_date, end_date, user_id)
    end

    test "return empty list if no transaction is found for specified interval" do
      %{id: user_id, account_id: account_id} = insert!(:user_with_account)
      start_date = "2023-08-01T00:00:00.911400Z"
      end_date = "2023-08-30T00:00:00.911400Z"

      _transaction_out_of_range =
        insert!(:transaction, sender_id: account_id, inserted_at: ~U[2023-10-01T00:00:00.911400Z])

      assert {:ok, []} == Transactions.get_transactions_by_interval(start_date, end_date, user_id)
    end
  end
end
