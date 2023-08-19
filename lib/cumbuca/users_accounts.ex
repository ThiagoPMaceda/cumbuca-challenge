defmodule Cumbuca.UsersAccounts do
  @moduledoc """
  The Users Accounts context.
  """

  alias Cumbuca.Accounts.Account
  alias Cumbuca.Users.User
  alias Cumbuca.Repo
  alias Ecto.Multi

  @doc """
  Creates a user and a account.


  ## Examples

      iex> create_user_and_account(%{field: value})
      {:ok, %User{}}

      iex> create_user_and_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_user_and_account(user_and_account) do
    user = Map.take(user_and_account, ["cpf", "name", "surname", "password"])
    balance_value = Map.get(user_and_account, "balance")

    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, user))
    |> Multi.insert(:account, fn %{user: user} ->
      Account.changeset(%Account{}, %{balance: balance_value, user_id: user.id})
    end)
    |> Repo.transaction()
    |> handle_multi()
  end

  defp handle_multi({:error, _id, changeset, _multi}), do: {:error, changeset}
  defp handle_multi({:ok, multi_result}), do: {:ok, multi_result}
end
