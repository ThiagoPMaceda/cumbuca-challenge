defmodule CumbucaWeb.AccountControllerTest do
  use CumbucaWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST /api/v1/accounts" do
    test "renders balance for user using token", %{conn: conn} do
      %{id: account_id, balance: balance} = insert!(:account, balance: 123_00)

      user = insert!(:user_with_account, account_id: account_id)

      response =
        conn
        |> put_authorization(user)
        |> get(~p"/api/v1/accounts")
        |> json_response(200)

      assert %{"balance" => balance} == response
    end

    test "renders error when token is missing", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/v1/accounts")
        |> json_response(401)

      assert response == %{
               "errors" =>
                 "An authorized JWT must be provided within the authorization header using the Bearer realm.",
               "message" => "Unauthorized"
             }
    end
  end
end
