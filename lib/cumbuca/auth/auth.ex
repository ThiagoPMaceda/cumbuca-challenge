defmodule Cumbuca.Auth do
  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.Schemas.User
  alias CumbucaWeb.Guardian
  alias Cumbuca.Auth.Token

  def login_with_cpf_and_password(%{cpf: cpf, password: password}) do
    with %User{} = user <- Accounts.get_user_by_cpf(cpf),
         {:ok, _user} <- Token.check_password(user, password),
         {:ok, token, _claims} <-
           Guardian.encode_and_sign(user, %{typ: "access"}, ttl: {1, :day}) do
      {:ok, token}
    else
      _ ->
        {:error, "invalid credentials"}
    end
  end
end
