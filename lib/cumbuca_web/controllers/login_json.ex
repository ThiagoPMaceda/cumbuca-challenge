defmodule CumbucaWeb.LoginJSON do
  def create(%{token: token}) do
    %{
      token: token
    }
  end
end
