defmodule Cumbuca.Accounts.AccountTest do
  use Cumbuca.DataCase

  alias Cumbuca.Accounts.Account

  describe "changeset/2" do
    test "with valid data returns valid changeset" do
      attrs = %{balance: 42_000, user_id: Ecto.UUID.generate()}

      changeset = Account.changeset(%Account{}, attrs)

      assert changeset.valid?
      assert changeset.changes == attrs
    end

    test "with invalid data returns error changeset" do
      changeset = Account.changeset(%Account{}, %{})

      refute changeset.valid?

      assert errors_on(changeset) == %{balance: ["can't be blank"], user_id: ["can't be blank"]}
    end

    test "with negative balance returns error changeset" do
      negative_balance_attrs = %{balance: -32_000, user_id: Ecto.UUID.generate()}
      changeset = Account.changeset(%Account{}, negative_balance_attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{balance: ["must be greater than 0"]}
    end

    test "without user in database returns error changeset" do
      without_user_id_attrs = %{balance: 42_000, user_id: Ecto.UUID.generate()}

      changeset = Account.changeset(%Account{}, without_user_id_attrs)

      assert {:error, result} = Repo.insert(changeset)

      assert errors_on(result) == %{user_id: ["does not exist"]}
    end
  end
end
