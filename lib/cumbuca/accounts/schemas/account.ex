defmodule Cumbuca.Accounts.Schemas.Account do
  @moduledoc """
  The Account schema.
  """
  use Cumbuca.Schema

  alias Cumbuca.Accounts.Schemas.User

  schema "accounts" do
    field :balance, :integer

    has_one :user, User
    timestamps()
  end

  @required [:balance]

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_number(:balance, greater_than: 0)
    |> cast_assoc(:user, required: true, with: &User.changeset/2)
  end
end
