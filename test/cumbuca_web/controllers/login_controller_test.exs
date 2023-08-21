defmodule CumbucaWeb.LoginControllerTest do
  use CumbucaWeb.ConnCase

  alias Cumbuca.Guardian

  @create_attrs %{
    password: "a1b2cz#T",
    cpf: "099.341.822-89"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "login" do
    test "renders token when data is valid", %{conn: conn} do
      insert!(:user_with_account,
        cpf: "09934182289",
        password: @create_attrs.password,
        password_hash: Argon2.hash_pwd_salt(@create_attrs.password)
      )

      response =
        conn
        |> post(~p"/api/v1/login", @create_attrs)
        |> json_response(200)

      %{"token" => token} = response

      assert {:ok, %{"typ" => "access", "sub" => "09934182289"}} =
               Guardian.decode_and_verify(token)
    end

    test "renders errors when user or password are invalid", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/v1/login", %{cpf: "invalid cpf", password: "invalid password"})
        |> json_response(401)

      assert response == %{
               "message" => "Unauthorized",
               "errors" => "invalid credentials"
             }
    end

    test "renders errors when params are missing", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/v1/login", %{})
        |> json_response(422)

      assert response == %{
               "errors" => %{"cpf" => ["can't be blank"], "password" => ["can't be blank"]},
               "message" => "Unprocessable entity"
             }
    end
  end
end
