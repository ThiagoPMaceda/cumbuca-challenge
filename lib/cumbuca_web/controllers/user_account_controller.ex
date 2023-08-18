defmodule CumbucaWeb.UserAccountController do
  use CumbucaWeb, :controller
  use Params

  alias Cumbuca.UsersAccounts

  defparams(
    user_account_params(%{
      name!: :string,
      surname!: :string,
      balance!: :integer,
      cpf!: :string
    })
  )

  action_fallback CumbucaWeb.FallbackController

  def create(conn, params) do
    with {:ok, %{account: account, user: user}} <-
           UsersAccounts.create_user_and_account(params) do
      conn
      |> put_status(:created)
      |> render(:show, %{account: account, user: user})
    end
  end
end
