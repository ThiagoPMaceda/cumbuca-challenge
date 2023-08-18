defmodule Cumbuca.Users.User do
  @moduledoc """
  The User schema.
  """
  use Cumbuca.Schema

  alias Cumbuca.Accounts.Account

  schema "users" do
    field :cpf, :string
    field :name, :string
    field :surname, :string

    has_one :accounts, Account

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :surname, :cpf])
    |> validate_required([:name, :surname, :cpf])
    |> unique_constraint(:cpf)
  end
end
