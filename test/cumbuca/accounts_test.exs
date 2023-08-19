defmodule Cumbuca.AccountsTest do
  use Cumbuca.DataCase

  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.Account

  describe "accounts" do
    test "create_account/1 with valid data creates a account" do
      user = insert!(:user)
      attrs = %{balance: 42_000, user_id: user.id}

      assert {:ok, %Account{} = account} = Accounts.create_account(attrs)
      assert account.balance == 42_000
      assert account.user_id == user.id
    end

    test "create_account/1 with invalid data returns error changeset" do
      {:error, changeset} = Accounts.create_account(%{})

      assert errors_on(changeset) == %{balance: ["can't be blank"], user_id: ["can't be blank"]}
    end

    test "create_account/1 handles foreign key constraint" do
      user_id = Ecto.UUID.generate()
      {:error, changeset} = Accounts.create_account(%{balance: 200, user_id: user_id})

      assert errors_on(changeset) == %{user_id: ["does not exist"]}
    end

    test "create_account/1 with negative initial balance returns error changeset" do
      user_id = Ecto.UUID.generate()
      {:error, changeset} = Accounts.create_account(%{balance: -30_000, user_id: user_id})

      assert errors_on(changeset) == %{balance: ["must be greater than 0"]}
    end
  end
end
