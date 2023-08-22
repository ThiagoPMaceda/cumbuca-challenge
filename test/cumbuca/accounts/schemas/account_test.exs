defmodule Cumbuca.Accounts.Schemas.AccountTest do
  use Cumbuca.DataCase, async: true

  alias Cumbuca.Accounts.Schemas.Account

  @attrs %{
    balance: 42_000,
    user: %{
      cpf: "34645544063",
      password: "A1b4$%2b",
      name: "Joe",
      surname: "Doe"
    }
  }

  describe "changeset/2" do
    test "with valid data returns valid changeset" do
      changeset = Account.changeset(%Account{}, @attrs)

      %{balance: balance, user: user_changeset} = changeset.changes

      %{cpf: cpf, password: password, name: name, surname: surname, password_hash: password_hash} =
        user_changeset.changes

      assert changeset.valid?
      assert balance == @attrs.balance
      assert cpf == @attrs.user.cpf
      assert password == @attrs.user.password
      assert surname == @attrs.user.surname
      assert name == @attrs.user.name
      assert true == Argon2.verify_pass(password, password_hash)
    end

    test "with missing data returns error changeset" do
      changeset = Account.changeset(%Account{}, %{})

      refute changeset.valid?

      assert errors_on(changeset) == %{balance: ["can't be blank"], user: ["can't be blank"]}
    end

    test "with missing user data returns error changeset" do
      changeset = Account.changeset(%Account{}, %{@attrs | user: %{name: "Joe"}})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               user: %{
                 cpf: ["can't be blank"],
                 password: ["can't be blank"],
                 surname: ["can't be blank"]
               }
             }
    end

    test "with negative balance returns error changeset" do
      negative_balance = -32_000
      changeset = Account.changeset(%Account{}, %{@attrs | balance: negative_balance})

      refute changeset.valid?

      assert errors_on(changeset) == %{balance: ["must be greater than 0"]}
    end
  end
end
