defmodule Cumbuca.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Cumbuca.Repo

  alias Cumbuca.Accounts.Account

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
end
