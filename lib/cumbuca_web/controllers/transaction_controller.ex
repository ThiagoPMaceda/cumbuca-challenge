defmodule CumbucaWeb.TransactionController do
  use CumbucaWeb, :controller

  alias Cumbuca.Transactions
  alias Ecto.UUID

  filter_for(:create, required: [:sender_id, :recipient_id, :amount])

  filter_for(:chargeback, required: [transaction_id: UUID])

  action_fallback(CumbucaWeb.FallbackController)

  def create(conn, params) do
    with {:ok, transaction} <- Transactions.create_transaction(params) do
      conn
      |> put_status(:created)
      |> render(:show, transaction: transaction)
    end
  end

  def chargeback(conn, params) do
    with {:ok, transaction} <- Transactions.chargeback(params) do
      conn
      |> put_status(:ok)
      |> render(:chargeback, transaction: transaction)
    end
  end
end
