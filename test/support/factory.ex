defmodule Cumbuca.Factory do
  @moduledoc false
  alias Cumbuca.Repo
  alias Cumbuca.Accounts.Schemas.{Account, User}

  def build(:user) do
    %User{
      cpf: "414.666.631-70",
      name: "Joe",
      surname: "Doe",
      password: "1a2b3c#0",
      password_hash: Argon2.hash_pwd_salt("1a2b3c#0")
    }
  end

  def build(:account) do
    %Account{balance: 50_000}
  end

  def build(:user_with_account) do
    account = insert!(:account)

    %User{
      cpf: "414.666.631-70",
      name: "Joe",
      surname: "Doe",
      password: "1a2b3c#0",
      password_hash: Argon2.hash_pwd_salt("1a2b3c#0"),
      account_id: account.id
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
