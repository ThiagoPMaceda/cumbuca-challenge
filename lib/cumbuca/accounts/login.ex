defmodule Cumbuca.Accounts.Login do
  @moduledoc """
  The Login schema.
  """
  use Cumbuca.Schema

  schema "login" do
    field :cpf, :string
    field :password, :string
  end

  @required [:cpf, :password]

  @doc false
  def changeset(login, attrs) do
    login
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end
