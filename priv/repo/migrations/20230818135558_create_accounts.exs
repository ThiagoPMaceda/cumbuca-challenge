defmodule Cumbuca.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :balance, :integer, null: false
      add :user_id, references(:users), null: false

      timestamps()
    end
  end
end
