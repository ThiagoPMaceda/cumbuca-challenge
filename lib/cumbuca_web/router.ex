defmodule CumbucaWeb.Router do
  use CumbucaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authentication do
    plug(CumbucaWeb.Plugs.Authentication)
  end

  scope "/api/v1", CumbucaWeb do
    pipe_through :api

    post "/sign-in", SignInController, :create
    post "/login", LoginController, :create
  end

  scope "/api/v1", CumbucaWeb do
    pipe_through [:api, :authentication]

    scope("/transactions") do
      resources "/", TransactionController, only: [:index, :create]
      post "/chargeback", TransactionController, :chargeback
    end
  end
end
