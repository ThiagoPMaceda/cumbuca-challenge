defmodule Cumbuca.Transactions.Schemas.Transaction do
  @moduledoc """
  The Transaction schema.
  """
  use Cumbuca.Schema

  alias Cumbuca.Accounts.Schemas.Account

  schema "transactions" do
    field(:recipient_id, :binary_id)
    field(:amount, :integer)
    field(:chargeback, :boolean, default: false)
    field(:chargeback_date, :utc_datetime_usec)

    belongs_to(:account, Account, foreign_key: :sender_id)

    timestamps()
  end

  @required [:sender_id, :recipient_id, :amount]
  @optional [:chargeback, :chargeback_date]

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:recipient_id)
  end
end
