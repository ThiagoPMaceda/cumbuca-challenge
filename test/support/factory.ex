defmodule Cumbuca.Factory do
  @moduledoc false
  alias Cumbuca.Repo
  alias Cumbuca.Users.User
  alias Cumbuca.Accounts.Account

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
    %Account{balance: 50_000, user_id: Ecto.UUID.generate()}
  end

  def build(:user_with_account) do
    user = insert!(:user)

    %Account{balance: 100_000, user_id: user.id}
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
