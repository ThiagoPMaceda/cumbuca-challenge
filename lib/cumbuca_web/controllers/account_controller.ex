defmodule CumbucaWeb.AccountController do
  use CumbucaWeb, :controller

  alias Cumbuca.Accounts
  alias Cumbuca.Accounts.Schemas.Account
  alias CumbucaWeb.Guardian.Plug

  action_fallback CumbucaWeb.FallbackController

  def balance(conn, _params) do
    %{id: user_id} = Plug.current_resource(conn)

    with %Account{} = account <- Accounts.get_account_by_user_id(user_id) do
      conn
      |> put_status(:ok)
      |> render(:balance, account: account)
    end
  end
end
