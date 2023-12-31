defmodule Cumbuca.Accounts.Schemas.Account do
  @moduledoc """
  The Account schema.
  """
  use Cumbuca.Schema

  alias Cumbuca.Accounts.Schemas.User
  alias Cumbuca.Transactions.Schemas.Transaction

  schema "accounts" do
    field :balance, :integer

    has_one :user, User
    has_many :transactions, Transaction, foreign_key: :sender_id
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
