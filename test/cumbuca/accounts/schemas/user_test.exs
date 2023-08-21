defmodule Cumbuca.Accounts.Schemas.UserTest do
  use Cumbuca.DataCase

  alias Cumbuca.Accounts.Schemas.User

  @attrs %{
    cpf: "34645544063",
    password: "A1b4$%2b",
    name: "Joe",
    surname: "Doe",
    account_id: Ecto.UUID.generate()
  }

  describe "changeset/2" do
    test "with valid data returns valid changeset" do
      changeset = User.changeset(%User{}, @attrs)

      {password_hash_from_changeset, changeset_without_password_hash} =
        Map.pop(changeset.changes, :password_hash)

      assert changeset.valid?
      assert changeset_without_password_hash == @attrs
      assert Argon2.verify_pass(@attrs.password, password_hash_from_changeset)
    end

    test "with missing data returns error changeset" do
      changeset = User.changeset(%User{}, %{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               cpf: ["can't be blank"],
               password: ["can't be blank"],
               name: ["can't be blank"],
               surname: ["can't be blank"]
             }
    end

    test "with invalid password returns error changeset" do
      invalid_password = "a1"
      changeset = User.changeset(%User{}, %{@attrs | password: invalid_password})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               password: ["at least one upper case character", "at least five characters"]
             }
    end

    test "with invalid CPF returns error changeset" do
      invalid_cpf = "34645544"
      changeset = User.changeset(%User{}, %{@attrs | cpf: invalid_cpf})

      refute changeset.valid?

      assert errors_on(changeset) == %{cpf: ["has invalid format"]}
    end

    test "handles unique CPF constraint" do
      duplicate_cpf = "34645544063"
      user = insert!(:user_with_account, cpf: duplicate_cpf)

      changeset =
        User.changeset(%User{}, %{@attrs | cpf: duplicate_cpf, account_id: user.account_id})

      {:error, result} = Repo.insert(changeset)

      assert errors_on(result) == %{cpf: ["has already been taken"]}
    end

    test "without account in database returns error changeset" do
      changeset = User.changeset(%User{}, @attrs)

      assert {:error, result} = Repo.insert(changeset)

      assert errors_on(result) == %{account_id: ["does not exist"]}
    end
  end
end
