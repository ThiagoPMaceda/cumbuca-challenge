defmodule Cumbuca.Accounts.Schemas.User do
  @moduledoc """
  The User schema.
  """
  use Cumbuca.Schema

  alias Cumbuca.Accounts.Schemas.Account
  alias Cumbuca.Auth.Token

  schema "users" do
    field :cpf, :string
    field :name, :string
    field :surname, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    belongs_to :account, Account

    timestamps()
  end

  @required [:name, :surname, :cpf, :password]
  @optional [:account_id]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_cpf()
    |> update_change(:cpf, &String.replace(&1, ~r/[^0-9]/, ""))
    |> validate_password()
    |> put_pass_hash()
    |> unique_constraint(:cpf)
    |> foreign_key_constraint(:account_id)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 5, message: "at least five characters")
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Token.hash_password(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp validate_cpf(%Ecto.Changeset{valid?: true, changes: %{cpf: cpf}} = changeset) do
    case Brcpfcnpj.cpf_valid?(cpf) do
      false -> Ecto.Changeset.add_error(changeset, :cpf, "has invalid format")
      true -> changeset
    end
  end

  defp validate_cpf(changeset), do: changeset
end
