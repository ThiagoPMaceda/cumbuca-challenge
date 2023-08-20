defmodule Cumbuca.AccountsTest do
  use Cumbuca.DataCase

  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.Account

  describe "create_account/1" do
    test "with valid data creates a account" do
      user = insert!(:user)
      attrs = %{balance: 42_000, user_id: user.id}

      assert {:ok, %Account{} = account} = Accounts.create_account(attrs)

      assert Repo.get_by(id: account.id, balance: account.balance, user_id: account.user_id)
    end

    test "with invalid data returns error changeset" do
      {:error, changeset} = Accounts.create_account(%{})

      assert errors_on(changeset) == %{balance: ["can't be blank"], user_id: ["can't be blank"]}
    end
  end
end
