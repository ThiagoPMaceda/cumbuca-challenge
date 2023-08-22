defmodule CumbucaWeb.Router do
  use CumbucaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", CumbucaWeb do
    pipe_through :api

    post "/sign-in", SignInController, :create
    post "/login", LoginController, :create
    post "/transactions", TransactionController, :create
    post "/transactions/chargeback", TransactionController, :chargeback
  end
end
