defmodule CumbucaWeb.TransactionControllerTest do
  use CumbucaWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup do
    account_one = insert!(:account, balance: 1_500_35)
    account_two = insert!(:account, balance: 300_00)

    {:ok, %{account_one: account_one, account_two: account_two}}
  end

  describe "POST /api/v1/transactions" do
    test "renders transaction when data is valid", %{
      account_one: account_one,
      account_two: account_two,
      conn: conn
    } do
      %{id: account_one_id, balance: account_one_balance} = account_one
      %{id: account_two_id, balance: account_two_balance} = account_two

      create_attrs = %{
        "sender_id" => account_one_id,
        "recipient_id" => account_two_id,
        "amount" => 1_000_00
      }

      response =
        conn
        |> post(~p"/api/v1/transactions", create_attrs)
        |> json_response(201)

      assert %{
               "id" => _,
               "sender_id" => ^account_one_id,
               "recipient_id" => ^account_two_id,
               "amount" => 1_000_00
             } = response

      assert account_one_balance == 150_035
      assert account_two_balance == 30_000
    end

    test "renders error message when balance is insufficient to make a transaction", %{
      account_one: account_one,
      account_two: account_two,
      conn: conn
    } do
      %{id: account_one_id} = account_one
      %{id: account_two_id} = account_two

      create_attrs = %{
        "sender_id" => account_one_id,
        "recipient_id" => account_two_id,
        "amount" => 91_000_00
      }

      response =
        conn
        |> post(~p"/api/v1/transactions", create_attrs)
        |> json_response(422)

      assert response == %{
               "errors" => "insufficient funds to make transaction",
               "message" => "Unprocessable entity"
             }
    end

    test "renders error if any of the account are not found", %{
      conn: conn
    } do
      create_attrs = %{
        "sender_id" => Ecto.UUID.generate(),
        "recipient_id" => Ecto.UUID.generate(),
        "amount" => 500
      }

      response =
        conn
        |> post(~p"/api/v1/transactions", create_attrs)
        |> json_response(422)

      assert response == %{
               "errors" => "sender or receiver account not found",
               "message" => "Unprocessable entity"
             }
    end
  end
end
