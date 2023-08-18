defmodule Cumbuca.Accounts.Account do
  @moduledoc """
  The Account schema.
  """
  use Cumbuca.Schema

  alias Cumbuca.Users.User

  schema "accounts" do
    field :balance, :integer

    belongs_to :user, User
    timestamps()
  end

  @required [:balance, :user_id]

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_number(:balance, greater_than: 0)
    |> foreign_key_constraint(:user_id)
  end
end
