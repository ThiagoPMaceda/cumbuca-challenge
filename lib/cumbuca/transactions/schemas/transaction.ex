defmodule Cumbuca.Transactions.Schemas.Transaction do
  @moduledoc """
  The Transaction schema.
  """
  use Cumbuca.Schema

  alias Cumbuca.Accounts.Schemas.Account

  schema "transactions" do
    field(:sender_id, :binary_id)
    field(:recipient_id, :binary_id)
    field(:amount, :integer)

    belongs_to(:account, Account)

    timestamps()
  end

  @required [:sender_id, :recipient_id, :amount]

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:recipient_id)
  end
end
