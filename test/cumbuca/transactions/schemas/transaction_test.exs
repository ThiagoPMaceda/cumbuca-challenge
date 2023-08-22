defmodule Cumbuca.Transactions.Schemas.TransactionTest do
  use Cumbuca.DataCase, async: true

  alias Cumbuca.Transactions.Schemas.Transaction

  @attrs %{
    sender_id: Ecto.UUID.generate(),
    recipient_id: Ecto.UUID.generate(),
    amount: 100_000,
    chargeback: true,
    chargeback_date: DateTime.utc_now()
  }

  describe "changeset/2" do
    test "with valid data returns valid changeset" do
      changeset = Transaction.changeset(%Transaction{}, @attrs)

      assert changeset.valid?
      assert changeset.changes
    end

    test "with missing data returns error changeset" do
      changeset = Transaction.changeset(%Transaction{}, %{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               amount: ["can't be blank"],
               recipient_id: ["can't be blank"],
               sender_id: ["can't be blank"]
             }
    end

    test "when sender_id does not exist returns error changeset" do
      changeset = Transaction.changeset(%Transaction{}, @attrs)

      {:error, result} = Repo.insert(changeset)

      assert errors_on(result) == %{sender_id: ["does not exist"]}
    end

    test "when recipient_id does not exist returns error changeset" do
      account = insert!(:account)
      changeset = Transaction.changeset(%Transaction{}, %{@attrs | recipient_id: account.id})

      {:error, result} = Repo.insert(changeset)

      assert errors_on(result) == %{sender_id: ["does not exist"]}
    end

    test "with negative amount returns error changeset" do
      negative_amount = -50_000
      changeset = Transaction.changeset(%Transaction{}, %{@attrs | amount: negative_amount})

      refute changeset.valid?

      assert errors_on(changeset) == %{amount: ["must be greater than 0"]}
    end
  end
end
