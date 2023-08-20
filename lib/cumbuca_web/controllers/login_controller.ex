defmodule CumbucaWeb.LoginController do
  use CumbucaWeb, :controller

  alias Cumbuca.Authentication

  action_fallback CumbucaWeb.FallbackController

  def create(conn, params) do
    with {:ok, token} <- Authentication.authenticate_with_cpf_and_password(params) do
      conn
      |> put_status(:ok)
      |> render(:create, token: token)
    end
  end
end
