defmodule Cumbuca.AuthenticationTest do
  use Cumbuca.DataCase

  alias Cumbuca.Authentication
  alias Cumbuca.Guardian

  describe "authenticate_with_cpf_and_password/1" do
    test "returns ok tuple if authentication is successful" do
      password = "a1b8P#29"
      password_hash = Argon2.hash_pwd_salt(password)
      cpf = "34645544063"
      attrs = %{"cpf" => cpf, "password" => password}

      insert!(:user, cpf: cpf, password: password, password_hash: password_hash)

      assert {:ok, token} = Authentication.authenticate_with_cpf_and_password(attrs)
      assert {:ok, %{"typ" => "access", "sub" => ^cpf}} = Guardian.decode_and_verify(token)
    end

    test "returns error tuple if there is a error in auth process" do
      password = "a1b8P#29"
      password_hash = Argon2.hash_pwd_salt("123")
      cpf = "34645544063"
      attrs = %{"cpf" => cpf, "password" => password}

      insert!(:user, cpf: cpf, password: password, password_hash: password_hash)

      assert {:error, "invalid credentials"} ==
               Authentication.authenticate_with_cpf_and_password(attrs)
    end

    test "returns a changeset error if data is invalid or missing" do
      {:error, changeset} = Authentication.authenticate_with_cpf_and_password(%{})

      assert errors_on(changeset) == %{cpf: ["can't be blank"], password: ["can't be blank"]}
    end
  end
end
