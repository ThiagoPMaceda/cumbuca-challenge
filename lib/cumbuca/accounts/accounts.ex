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

  def get_sender_and_recipient_accounts(id_list, sender_id, recipient_id) do
    accounts =
      Account
      |> where([a], a.id in ^id_list)
      |> Repo.all()

    sender_account = Enum.find(accounts, &(&1.id == sender_id))
    recipient_account = Enum.find(accounts, &(&1.id == recipient_id))

    case is_nil(sender_account) || is_nil(recipient_account) do
      true -> {:error, :account_not_found}
      false -> {:ok, [sender_account, recipient_account]}
    end
  end

  def get_account_by_id(account_id) do
    Repo.get(Account, account_id)
  end

  def get_user_by_id(user_id) do
    Repo.get(User, user_id)
  end

  def get_user_by_cpf(cpf) do
    formatted_cpf = String.replace(cpf, ~r/[^0-9]/, "")
    Repo.get_by(User, cpf: formatted_cpf)
  end

  def get_account_by_user_id(user_id) do
    %User{account_id: account_id} = get_user_by_id(user_id)

    get_account_by_id(account_id)
  end
end
