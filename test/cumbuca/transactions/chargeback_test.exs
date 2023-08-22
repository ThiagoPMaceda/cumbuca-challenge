defmodule Cumbuca.Transactions.ChargebackTest do
  use Cumbuca.DataCase

  alias Cumbuca.Transactions.Chargeback
  alias Cumbuca.Accounts.Schemas.Account

  describe "process/1" do
    test "chargeback a transaction returning amount for sender and removing amount for recipient" do
      %{id: sender_id} = insert!(:account, balance: 20000)
      %{id: recipient_id} = insert!(:account, balance: 20000)

      transaction_to_chargeback =
        insert!(:transaction,
          sender_id: sender_id,
          recipient_id: recipient_id,
          amount: 10_00
        )

      {:ok, transaction} = Chargeback.process(%{transaction_id: transaction_to_chargeback.id})

      sender_after_chargeback = Repo.get(Account, sender_id)
      recipient_after_chargeback = Repo.get(Account, recipient_id)

      assert transaction.chargeback == true
      assert sender_after_chargeback.balance == 21000
      assert recipient_after_chargeback.balance == 19000
    end

    test "returns error when recipient does not have enough funds" do
      %{id: sender_id} = insert!(:account, balance: 20000)
      %{id: recipient_id} = insert!(:account, balance: 100_00)

      transaction_to_chargeback =
        insert!(:transaction,
          sender_id: sender_id,
          recipient_id: recipient_id,
          amount: 100_00_00
        )

      assert {:error, :insufficient_funds_for_chargeback} ==
               Chargeback.process(%{transaction_id: transaction_to_chargeback.id})
    end

    test "returns error when transaction id is not found" do
      assert {:error, :transaction_not_found} ==
               Chargeback.process(%{transaction_id: Ecto.UUID.generate()})
    end
  end
end
