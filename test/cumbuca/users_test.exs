defmodule Cumbuca.UsersTest do
  use Cumbuca.DataCase

  alias Cumbuca.Users

  describe "users" do
    alias Cumbuca.Users.User

    @valid_attrs %{cpf: "11111111111", name: "Joe", surname: "Doe"}
    @invalid_attrs %{cpf: nil, name: nil, surname: nil}

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.cpf == "11111111111"
      assert user.name == "Joe"
      assert user.surname == "Doe"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, changeset} = Users.create_user(@invalid_attrs)

      assert errors_on(changeset) == %{
               cpf: ["can't be blank"],
               name: ["can't be blank"],
               surname: ["can't be blank"]
             }
    end

    test "create_user/1 with duplicate cpf returns error changeset" do
      insert!(:user, cpf: "11111111111")

      assert {:error, changeset} = Users.create_user(@valid_attrs)

      assert errors_on(changeset) == %{cpf: ["has already been taken"]}
    end
  end
end
