defmodule CumbucaWeb.SignInController do
  use CumbucaWeb, :controller

  alias Cumbuca.Accounts

  @required_sign_in_params [
    :balance,
    user: [
      :name,
      :surname,
      :cpf,
      :password
    ]
  ]

  filter_for(:create, required: @required_sign_in_params)

  action_fallback CumbucaWeb.FallbackController

  def create(conn, params) do
    with {:ok, account} <- Accounts.create_account(params) do
      conn
      |> put_status(:created)
      |> render(:show, account: account)
    end
  end
end
