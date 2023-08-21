defmodule Cumbuca.AccountsTest do
  use Cumbuca.DataCase

  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.Schemas.{Account, User}

  @create_user_and_account_valid_attrs %{
    "balance" => 234_500,
    "user" => %{
      "cpf" => "584.602.439-40",
      "name" => "jane",
      "surname" => "doe",
      "password" => "z0y9#3E2"
    }
  }

  describe "create_account/1" do
    test "with valid data creates a account" do
      assert {:ok, %Account{} = account} =
               Accounts.create_account(@create_user_and_account_valid_attrs)

      %Account{user: user} = Repo.preload(account, [:user])

      assert Repo.get_by(Account,
               id: account.id,
               balance: account.balance
             )

      assert Repo.get_by(User,
               id: user.id,
               cpf: user.cpf
             )
    end

    test "with missing data returns error changeset" do
      {:error, changeset} = Accounts.create_account(%{})

      assert errors_on(changeset) == %{balance: ["can't be blank"], user: ["can't be blank"]}
    end

    test "with missing user data returns error changeset" do
      {:error, changeset} = Accounts.create_account(%{balance: 10, user: %{name: "joe"}})

      assert errors_on(changeset) == %{
               user: %{
                 cpf: ["can't be blank"],
                 password: ["can't be blank"],
                 surname: ["can't be blank"]
               }
             }
    end
  end

  describe "get_by_ids/1" do
    test "returns list of accounts if ids are found" do
      %{id: account_one_id} = insert!(:account)
      %{id: account_two_id} = insert!(:account)
      %{id: account_three_id} = insert!(:account)
      id_list = [account_one_id, account_two_id, account_three_id]

      accounts = Accounts.get_by_ids(id_list)

      assert [
               %Account{id: ^account_one_id},
               %Account{id: ^account_two_id},
               %Account{id: ^account_three_id}
             ] = accounts
    end

    test "returns empty list if ids are not found" do
      assert Accounts.get_by_ids([Ecto.UUID.generate()]) == []
    end
  end
end
