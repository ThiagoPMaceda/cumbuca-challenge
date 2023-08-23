defmodule Cumbuca.AccountsTest do
  use Cumbuca.DataCase, async: true

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

  describe "get_account_by_id/1" do
    test "returns a account if account with id is found" do
      %{id: account_id} = insert!(:account)

      %Account{id: ^account_id} = assert Accounts.get_account_by_id(account_id)
    end

    test "returns nil if account with id is not found" do
      assert is_nil(Accounts.get_account_by_id(Ecto.UUID.generate()))
    end
  end

  describe "get_user_by_id/1" do
    test "returns a user if user with id is found" do
      %{id: user_id} = insert!(:user_with_account)

      %User{id: ^user_id} = assert Accounts.get_user_by_id(user_id)
    end

    test "returns nil if user with id is not found" do
      assert is_nil(Accounts.get_user_by_id(Ecto.UUID.generate()))
    end
  end

  describe "get_user_by_cpf/1" do
    test "formats CPF and returns a user if user with CPF is found" do
      %{cpf: user_cpf} = insert!(:user_with_account, cpf: "34645544063")

      %User{cpf: ^user_cpf} = assert Accounts.get_user_by_cpf(user_cpf)
    end

    test "returns nil if user with id is not found" do
      assert is_nil(Accounts.get_user_by_cpf("34645544063"))
    end
  end

  describe "get_account_by_user_id/1" do
    test "returns a account if account with user id associated is found" do
      %{id: user_id, account_id: account_id} = insert!(:user_with_account)

      %Account{id: ^account_id} = assert Accounts.get_account_by_user_id(user_id)
    end
  end

  describe "get_sender_and_recipient_accounts/3" do
    test "returns a :ok and a list of accounts when accounts are found" do
      %{id: sender_id} = insert!(:account)
      %{id: recipient_id} = insert!(:account)
      id_list = [sender_id, recipient_id]

      result = Accounts.get_sender_and_recipient_accounts(id_list, sender_id, recipient_id)

      assert {:ok, [%Account{id: ^sender_id}, %Account{id: ^recipient_id}]} = result
    end

    test "returns a :error if either account is not found" do
      %{id: sender_id} = insert!(:account)
      %{id: recipient_id} = insert!(:account)
      id_list_without_recipient_id = [sender_id, Ecto.UUID.generate()]
      id_list_without_sender_id = [Ecto.UUID.generate(), recipient_id]

      result_one =
        Accounts.get_sender_and_recipient_accounts(
          id_list_without_sender_id,
          sender_id,
          recipient_id
        )

      result_two =
        Accounts.get_sender_and_recipient_accounts(
          id_list_without_recipient_id,
          sender_id,
          recipient_id
        )

      assert {:error, :account_not_found} == result_one
      assert {:error, :account_not_found} == result_two
    end
  end
end
