defmodule CumbucaWeb.SignInControllerTest do
  use CumbucaWeb.ConnCase, async: true

  alias Cumbuca.Accounts.Schemas.{Account, User}

  @create_attrs %{
    balance: 2_459_900,
    user: %{
      name: "Joe",
      surname: "Doe",
      cpf: "099.341.822-89",
      password: "Zt8#ad1"
    }
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user account" do
    test "renders user and account when data is valid", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/v1/sign-in", @create_attrs)
        |> json_response(201)

      assert %{
               "account_id" => account_id,
               "balance" => 2_459_900,
               "cpf" => "09934182289",
               "name" => "Joe",
               "surname" => "Doe",
               "user_id" => user_id
             } = response

      assert Repo.get_by(Account,
               id: account_id,
               balance: @create_attrs.balance
             )

      assert Repo.get_by(User,
               id: user_id,
               cpf: "09934182289",
               name: @create_attrs.user.name,
               surname: @create_attrs.user.surname,
               account_id: account_id
             )
    end

    test "renders errors when necessary data to create user is missing", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/v1/sign-in", %{@create_attrs | user: %{surname: "Doe"}})
        |> json_response(422)

      assert response == %{
               "errors" => %{
                 "user" => %{
                   "cpf" => ["can't be blank"],
                   "name" => ["can't be blank"],
                   "password" => ["can't be blank"]
                 }
               },
               "message" => "Unprocessable entity"
             }
    end

    test "renders errors when necessary data to create account is missing", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/v1/sign-in", Map.drop(@create_attrs, [:balance]))
        |> json_response(422)

      assert response == %{
               "errors" => %{"balance" => ["can't be blank"]},
               "message" => "Unprocessable entity"
             }
    end

    test "renders errors when balance is negative", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/v1/sign-in", %{@create_attrs | balance: -123_000})
        |> json_response(422)

      assert response ==
               %{
                 "errors" => %{"balance" => ["must be greater than 0"]},
                 "message" => "Unprocessable entity"
               }
    end

    test "renders errors when cpf is already taken", %{conn: conn} do
      insert!(:user_with_account, cpf: "09934182289")

      response =
        conn
        |> post(~p"/api/v1/sign-in", @create_attrs)
        |> json_response(422)

      assert response ==
               %{
                 "errors" => %{"user" => %{"cpf" => ["has already been taken"]}},
                 "message" => "Unprocessable entity"
               }
    end
  end
end
