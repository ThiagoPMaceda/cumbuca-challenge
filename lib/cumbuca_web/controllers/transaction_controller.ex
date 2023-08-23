defmodule CumbucaWeb.TransactionController do
  use CumbucaWeb, :controller

  alias Cumbuca.Transactions
  alias Ecto.UUID
  alias CumbucaWeb.Guardian.Plug

  filter_for(:create, required: [:sender_id, :recipient_id, :amount])
  filter_for(:chargeback, required: [transaction_id: UUID])

  action_fallback(CumbucaWeb.FallbackController)

  def index(conn, %{"end_date" => end_date, "start_date" => start_date}) do
    %{id: user_id} = Plug.current_resource(conn)

    with {:ok, transactions} <-
           Transactions.get_transactions_by_interval(start_date, end_date, user_id) do
      conn
      |> put_status(:ok)
      |> render(:index, transactions: transactions)
    end
  end

  def index(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: CumbucaWeb.ErrorJSON)
    |> render(:"400",
      errors:
        "it's necessary to send `end_date` and `start_date` in the query params with the following format: 'yyyy-mm-dd'"
    )
  end

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
