defmodule Cumbuca.UsersTest do
  use Cumbuca.DataCase

  alias Cumbuca.Users

  describe "users" do
    alias Cumbuca.Users.User

    @attrs %{cpf: "346.455.440-63", name: "Joe", surname: "Doe", password: "a1Z@#do"}

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@attrs)
      assert user.cpf == "34645544063"
      assert user.name == "Joe"
      assert user.surname == "Doe"

      assert {:ok, _} = Argon2.check_pass(user, user.password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, changeset} = Users.create_user(%{})

      assert errors_on(changeset) == %{
               cpf: ["can't be blank"],
               name: ["can't be blank"],
               surname: ["can't be blank"],
               password: ["can't be blank"]
             }
    end

    test "create_user/1 with duplicate cpf returns error changeset" do
      insert!(:user, cpf: "34645544063")

      assert {:error, changeset} = Users.create_user(@attrs)

      assert errors_on(changeset) == %{cpf: ["has already been taken"]}
    end

    test "create_user/1 with invalid password returns error changeset" do
      assert {:error, changeset} = Users.create_user(%{@attrs | password: "abc"})

      assert errors_on(changeset) == %{
               password: [
                 "at least one digit or punctuation character",
                 "at least one upper case character",
                 "at least five characters"
               ]
             }
    end
  end
end
