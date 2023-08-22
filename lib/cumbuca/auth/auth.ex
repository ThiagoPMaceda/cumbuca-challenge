defmodule Cumbuca.Auth do
  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.Schemas.User
  alias Cumbuca.Auth.Schemas.Login
  alias CumbucaWeb.Guardian
  alias Ecto.Changeset

  def login_with_cpf_and_password(params) do
    with %Changeset{valid?: true} <- Login.changeset(%Login{}, params),
         %User{} = user <- Accounts.get_user_by_cpf(params["cpf"]),
         {:ok, _user} <- Argon2.check_pass(user, params["password"]),
         {:ok, token, _claims} <-
           Guardian.encode_and_sign(user, %{typ: "access"}, ttl: {1, :day}) do
      {:ok, token}
    else
      %Changeset{valid?: false} = changeset ->
        {:error, changeset}

      _ ->
        {:error, "invalid credentials"}
    end
  end
end
