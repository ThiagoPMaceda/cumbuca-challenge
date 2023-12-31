defmodule Cumbuca.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :surname, :string, null: false
      add :cpf, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:cpf])
  end
end
