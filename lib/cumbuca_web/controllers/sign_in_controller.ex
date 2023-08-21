defmodule CumbucaWeb.SignInController do
  use CumbucaWeb, :controller

  alias Cumbuca.Accounts

  action_fallback CumbucaWeb.FallbackController

  def create(conn, params) do
    with {:ok, account} <- Accounts.create_account(params) do
      conn
      |> put_status(:created)
      |> render(:show, account: account)
    end
  end
end
