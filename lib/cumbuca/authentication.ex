defmodule Cumbuca.Authentication do
  alias Cumbuca.Guardian
  alias Cumbuca.Users
  alias Cumbuca.Users.User
  alias Cumbuca.Accounts.Login
  alias Ecto.Changeset

  def authenticate_with_cpf_and_password(params) do
    with %Changeset{changes: %{cpf: cpf, password: password}} <-
           Login.changeset(%Login{}, params),
         %User{} = user <- Users.get_user_by_cpf(cpf),
         {:ok, _user} <- Argon2.check_pass(user, password),
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
