defmodule Cumbuca.Repo.Migrations.InvertIdFromUserIdInAccountToAccountIdInUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :account_id, references(:accounts), null: false
    end

    alter table("accounts") do
      remove :user_id
    end
  end
end
