defmodule Cumbuca.Schema do
  @moduledoc """
  Module that contains a macro that adds binary id for primary keys and foreign keys in Schemas.
  """
  defmacro __using__(_opts \\ []) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
