defmodule Cumbuca.AccountsTest do
  use Cumbuca.DataCase

  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.Account

  describe "accounts" do
    @invalid_attrs %{balance: nil, user_id: nil}

    test "create_account/1 with valid data creates a account" do
      user = insert!(:user)
      valid_attrs = %{balance: 42_000, user_id: user.id}

      assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs)
      assert account.balance == 42_000
      assert account.user_id == user.id
    end

    test "create_account/1 with invalid data returns error changeset" do
      {:error, changeset} = Accounts.create_account(@invalid_attrs)

      assert errors_on(changeset) == %{balance: ["can't be blank"], user_id: ["can't be blank"]}
    end

    test "create_account/1 handles foreign key constraint" do
      user_id = Ecto.UUID.generate()
      {:error, changeset} = Accounts.create_account(%{balance: 0, user_id: user_id})

      assert errors_on(changeset) == %{balance: ["must be greater than 0"]}
    end

    test "create_account/1 with negative initial balance returns error changeset" do
      user_id = Ecto.UUID.generate()
      {:error, changeset} = Accounts.create_account(%{balance: -30_000, user_id: user_id})

      assert errors_on(changeset) == %{balance: ["must be greater than 0"]}
    end
  end
end
