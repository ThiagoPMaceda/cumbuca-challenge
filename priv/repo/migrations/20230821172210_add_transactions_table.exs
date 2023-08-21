defmodule Cumbuca.Repo.Migrations.AddTransactionsTable do
  use Ecto.Migration

  def change do
    create table("transactions") do
      add(:sender_id, references(:accounts), null: false)
      add(:recipient_id, references(:accounts), null: false)
      add(:amount, :integer, null: false)

      timestamps()
    end
  end
end
