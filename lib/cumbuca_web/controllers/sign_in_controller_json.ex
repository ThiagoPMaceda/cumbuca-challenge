defmodule CumbucaWeb.SignInJSON do
  alias Cumbuca.Accounts.Schemas.Account

  def show(%{account: %Account{user: user} = account}) do
    %{
      account_id: account.id,
      balance: account.balance,
      cpf: user.cpf,
      name: user.name,
      surname: user.surname,
      user_id: user.id
    }
  end
end
