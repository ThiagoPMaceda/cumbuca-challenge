defmodule CumbucaWeb.AccountJSON do
  def balance(%{account: account}) do
    %{
      balance: account.balance
    }
  end
end
