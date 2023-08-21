defmodule CumbucaWeb.TransactionController do
  use CumbucaWeb, :controller

  alias Cumbuca.Transactions

  filter_for(:create, required: [:sender_id, :recipient_id, :amount])

  action_fallback(CumbucaWeb.FallbackController)

  def create(conn, params) do
    with {:ok, transaction} <- Transactions.create_transaction(params) do
      conn
      |> put_status(:created)
      |> render(:show, transaction: transaction)
    end
  end
end
