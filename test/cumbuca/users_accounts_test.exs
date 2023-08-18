defmodule Cumbuca.UsersAccountsTest do
  use Cumbuca.DataCase

  alias Cumbuca.UsersAccounts
  alias Cumbuca.Accounts.Account
  alias Cumbuca.Users.User

  @valid_attrs %{
    "cpf" => "11111111111",
    "name" => "Jane",
    "surname" => "Doe",
    "balance" => 234_500
  }

  describe "users accounts" do
    test "create_user_and_account/1 with valid data creates a user and account" do
      {:ok, %{account: %Account{} = account, user: %User{} = user}} =
        UsersAccounts.create_user_and_account(@valid_attrs)

      assert user.cpf == @valid_attrs["cpf"]
      assert user.name == @valid_attrs["name"]
      assert user.surname == @valid_attrs["surname"]

      assert account.balance == @valid_attrs["balance"]
      assert account.user_id == user.id
    end

    test "create_user_and_account/1 with duplicate cpf returns error changeset" do
      insert!(:user, cpf: "11111111111")
      {:error, changeset} = UsersAccounts.create_user_and_account(@valid_attrs)

      assert errors_on(changeset) == %{cpf: ["has already been taken"]}
    end

    test "create_user_and_account/1 with negative initial balance returns error changeset" do
      {:error, changeset} =
        UsersAccounts.create_user_and_account(%{@valid_attrs | "balance" => -342_000})

      assert errors_on(changeset) == %{balance: ["must be greater than 0"]}
    end
  end
end
