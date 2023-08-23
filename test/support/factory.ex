defmodule Cumbuca.Factory do
  @moduledoc false
  alias Cumbuca.Repo
  alias Cumbuca.Accounts.Schemas.{Account, User}
  alias Cumbuca.Transactions.Schemas.Transaction

  def build(:user) do
    %User{
      id: Ecto.UUID.generate(),
      cpf: "414.666.631-70",
      name: "Joe",
      surname: "Doe",
      password: "1a2b3c#0",
      password_hash: Argon2.hash_pwd_salt("1a2b3c#0")
    }
  end

  def build(:account) do
    %Account{id: Ecto.UUID.generate(), balance: 50_000}
  end

  def build(:user_with_account) do
    account = insert!(:account)

    %User{
      id: Ecto.UUID.generate(),
      cpf: "414.666.631-70",
      name: "Joe",
      surname: "Doe",
      password: "1a2b3c#0",
      password_hash: Argon2.hash_pwd_salt("1a2b3c#0"),
      account_id: account.id
    }
  end

  def build(:transaction) do
    %{id: sender_id} = insert!(:account)
    %{id: recipient_id} = insert!(:account)

    %Transaction{
      id: Ecto.UUID.generate(),
      sender_id: sender_id,
      recipient_id: recipient_id,
      amount: 10_00
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
