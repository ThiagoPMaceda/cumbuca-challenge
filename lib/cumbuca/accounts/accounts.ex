defmodule Cumbuca.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Cumbuca.Repo

  alias Cumbuca.Accounts.Schemas.{Account, User}

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def get_by_ids(id_list) do
    Account
    |> where([a], a.id in ^id_list)
    |> Repo.all()
  end

  def get_account_by_id(account_id) do
    Repo.get(Account, account_id)
  end

  def get_user_by_cpf(cpf) do
    formatted_cpf = String.replace(cpf, ~r/[^0-9]/, "")
    Repo.get_by(User, cpf: formatted_cpf)
  end
end
