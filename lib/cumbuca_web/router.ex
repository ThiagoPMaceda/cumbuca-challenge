defmodule CumbucaWeb.Router do
  use CumbucaWeb, :router

  alias UserAccountController

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", CumbucaWeb do
    pipe_through :api

    post "/users-accounts", UserAccountController, :create
  end
end
