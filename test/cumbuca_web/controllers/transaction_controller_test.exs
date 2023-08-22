defmodule CumbucaWeb.TransactionControllerTest do
  use CumbucaWeb.ConnCase

  alias Cumbuca.Accounts.Schemas.Account

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

  describe "POST /api/v1/transactions/chargeback" do
    test "chargebacks a transaction when data is valid", %{
      account_one: account_one,
      account_two: account_two,
      conn: conn
    } do
      %{id: sender_id, balance: sender_balance_before_chargeback} = account_one
      %{id: recipient_id, balance: recipient_balance_before_chargeback} = account_two

      %{id: transaction_id} =
        insert!(:transaction, sender_id: sender_id, recipient_id: recipient_id)

      attrs = %{"transaction_id" => transaction_id}

      response =
        conn
        |> post(~p"/api/v1/transactions/chargeback", attrs)
        |> json_response(200)

      assert %{
               "id" => _,
               "sender_id" => ^sender_id,
               "recipient_id" => ^recipient_id,
               "amount" => 1_000
             } = response

      %Account{balance: sender_balance_after_chargeback} = Repo.get(Account, sender_id)
      %Account{balance: recipient_balance_after_chargeback} = Repo.get(Account, recipient_id)

      assert sender_balance_before_chargeback == 150_035
      assert sender_balance_after_chargeback == 151_035

      assert recipient_balance_before_chargeback == 300_00
      assert recipient_balance_after_chargeback == 290_00
    end

    test "renders error message when balance is insufficient to make a transaction", %{
      account_one: account_one,
      account_two: account_two,
      conn: conn
    } do
      %{id: sender_id} = account_one
      %{id: recipient_id} = account_two

      %{id: transaction_id} =
        insert!(:transaction, sender_id: sender_id, recipient_id: recipient_id, amount: 1_000_000)

      attrs = %{"transaction_id" => transaction_id}

      response =
        conn
        |> post(~p"/api/v1/transactions/chargeback", attrs)
        |> json_response(422)

      assert response == %{
               "errors" => "insufficient funds to chargeback transaction",
               "message" => "Unprocessable entity"
             }
    end

    test "renders error message when transaction id is not found", %{conn: conn} do
      attrs = %{"transaction_id" => Ecto.UUID.generate()}

      response =
        conn
        |> post(~p"/api/v1/transactions/chargeback", attrs)
        |> json_response(422)

      assert response == %{
               "errors" => "transaction was not found",
               "message" => "Unprocessable entity"
             }
    end

    test "renders error message when params are missing", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/v1/transactions/chargeback", %{})
        |> json_response(400)

      assert response == %{
               "errors" => %{"transaction_id" => "is required"},
               "message" => "Bad request"
             }
    end
  end
end
