defmodule CumbucaWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  """
  use CumbucaWeb, :controller
  alias Ecto.Changeset
  alias StrongParams.Error

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    errors = Changeset.traverse_errors(changeset, &translate_error/1)

    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CumbucaWeb.ErrorJSON)
    |> render(:"422", errors: errors)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: CumbucaWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :transaction_not_found}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CumbucaWeb.ErrorJSON)
    |> render(:"422", errors: "transaction was not found")
  end

  def call(conn, {:error, :insufficient_funds}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CumbucaWeb.ErrorJSON)
    |> render(:"422", errors: "insufficient funds to make transaction")
  end

  def call(conn, {:error, :insufficient_funds_for_chargeback}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CumbucaWeb.ErrorJSON)
    |> render(:"422", errors: "insufficient funds to chargeback transaction")
  end

  def call(conn, {:error, :account_not_found}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CumbucaWeb.ErrorJSON)
    |> render(:"422", errors: "sender or receiver account not found")
  end

  def call(conn, {:error, "invalid credentials"}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: CumbucaWeb.ErrorJSON)
    |> render(:"401", errors: "invalid credentials")
  end

  def call(conn, %Error{errors: errors}) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: CumbucaWeb.ErrorJSON)
    |> render(:"400", errors: errors)
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
