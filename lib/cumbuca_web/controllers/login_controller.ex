defmodule CumbucaWeb.LoginController do
  use CumbucaWeb, :controller

  alias Cumbuca.Auth

  filter_for(:create, required: [:cpf, :password])

  action_fallback CumbucaWeb.FallbackController

  def create(conn, params) do
    with {:ok, token} <- Auth.login_with_cpf_and_password(params) do
      conn
      |> put_status(:ok)
      |> render(:create, token: token)
    end
  end
end
