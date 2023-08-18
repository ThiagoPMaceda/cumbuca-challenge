defmodule CumbucaWeb.UserAccountJSON do
  alias Cumbuca.Users.User
  alias Cumbuca.Accounts.Account

  @doc """
  Renders a single user account.
  """
  def show(%{user: %User{} = user, account: %Account{} = account}) do
    %{
      account_id: account.id,
      user_id: user.id,
      name: user.name,
      surname: user.surname,
      cpf: user.cpf,
      balance: account.balance
    }
  end
end
