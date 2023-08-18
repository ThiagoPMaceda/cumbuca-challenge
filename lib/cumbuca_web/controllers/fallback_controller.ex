defmodule CumbucaWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  """
  use CumbucaWeb, :controller
  alias Ecto.Changeset

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

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
