defmodule Cumbuca.AuthTest do
  use Cumbuca.DataCase, async: true

  alias Cumbuca.Auth
  alias CumbucaWeb.Guardian

  describe "login_with_cpf_and_password/1" do
    test "returns ok tuple if login is successful" do
      password = "a1b8P#29"
      password_hash = Argon2.hash_pwd_salt(password)
      cpf = "34645544063"
      attrs = %{cpf: cpf, password: password}

      %{id: user_id} =
        insert!(:user_with_account, cpf: cpf, password: password, password_hash: password_hash)

      assert {:ok, token} = Auth.login_with_cpf_and_password(attrs)
      assert {:ok, %{"typ" => "access", "sub" => ^user_id}} = Guardian.decode_and_verify(token)
    end

    test "returns error tuple if there is a error in login process" do
      password = "a1b8P#29"
      password_hash = Argon2.hash_pwd_salt("123")
      cpf = "34645544063"
      attrs = %{cpf: cpf, password: password}

      insert!(:user_with_account, cpf: cpf, password: password, password_hash: password_hash)

      assert {:error, "invalid credentials"} ==
               Auth.login_with_cpf_and_password(attrs)
    end
  end
end
