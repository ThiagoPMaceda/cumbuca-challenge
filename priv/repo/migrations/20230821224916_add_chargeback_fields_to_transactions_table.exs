defmodule Cumbuca.Repo.Migrations.AddChargebackFieldsToTransactionsTable do
  use Ecto.Migration

  def change do
    alter table("transactions") do
      add(:chargeback, :boolean, default: false)
      add(:chargeback_date, :utc_datetime)
    end
  end
end
