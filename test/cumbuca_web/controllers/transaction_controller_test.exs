defmodule CumbucaWeb.TransactionControllerTest do
  use CumbucaWeb.ConnCase, async: true

  alias Cumbuca.Accounts.Schemas.Account

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

      user = insert!(:user_with_account)

      response =
        conn
        |> put_authorization(user)
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

      user = insert!(:user_with_account)

      response =
        conn
        |> put_authorization(user)
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

      user = insert!(:user_with_account)

      response =
        conn
        |> put_authorization(user)
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
      user = insert!(:user_with_account)
      %{id: sender_id, balance: sender_balance_before_chargeback} = account_one
      %{id: recipient_id, balance: recipient_balance_before_chargeback} = account_two

      %{id: transaction_id} =
        insert!(:transaction, sender_id: sender_id, recipient_id: recipient_id)

      attrs = %{"transaction_id" => transaction_id}

      response =
        conn
        |> put_authorization(user)
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
      user = insert!(:user_with_account)
      %{id: sender_id} = account_one
      %{id: recipient_id} = account_two

      %{id: transaction_id} =
        insert!(:transaction, sender_id: sender_id, recipient_id: recipient_id, amount: 1_000_000)

      attrs = %{"transaction_id" => transaction_id}

      response =
        conn
        |> put_authorization(user)
        |> post(~p"/api/v1/transactions/chargeback", attrs)
        |> json_response(422)

      assert response == %{
               "errors" => "insufficient funds to chargeback transaction",
               "message" => "Unprocessable entity"
             }
    end

    test "renders an error message when a chargeback has already been processed for the transaction",
         %{
           account_one: account_one,
           account_two: account_two,
           conn: conn
         } do
      user = insert!(:user_with_account)
      %{id: sender_id} = account_one
      %{id: recipient_id} = account_two

      %{id: transaction_id} =
        insert!(:transaction, sender_id: sender_id, recipient_id: recipient_id, chargeback: true)

      attrs = %{"transaction_id" => transaction_id}

      response =
        conn
        |> put_authorization(user)
        |> post(~p"/api/v1/transactions/chargeback", attrs)
        |> json_response(422)

      assert response == %{
               "errors" => "The current transaction has already been chargebacked",
               "message" => "Unprocessable entity"
             }
    end

    test "renders error message when transaction id is not found", %{conn: conn} do
      user = insert!(:user_with_account)
      attrs = %{"transaction_id" => Ecto.UUID.generate()}

      response =
        conn
        |> put_authorization(user)
        |> post(~p"/api/v1/transactions/chargeback", attrs)
        |> json_response(422)

      assert response == %{
               "errors" => "transaction was not found",
               "message" => "Unprocessable entity"
             }
    end

    test "renders error message when params are missing", %{conn: conn} do
      user = insert!(:user_with_account)

      response =
        conn
        |> put_authorization(user)
        |> post(~p"/api/v1/transactions/chargeback", %{})
        |> json_response(400)

      assert response == %{
               "errors" => %{"transaction_id" => "is required"},
               "message" => "Bad request"
             }
    end
  end

  describe "GET /api/v1/transactions" do
    test "renders transactions list when data is valid", %{conn: conn} do
      user = %{account_id: account_id} = insert!(:user_with_account)

      attrs = %{
        "start_date" => "2023-08-01T00:00:00.911400Z",
        "end_date" => "2023-08-30T00:00:00.911400Z"
      }

      %{id: first_transaction_id} =
        insert!(:transaction,
          amount: 20_00,
          sender_id: account_id,
          inserted_at: ~U[2023-08-01T00:00:00.911400Z]
        )

      %{id: second_transaction_id} =
        insert!(:transaction,
          amount: 30_00,
          sender_id: account_id,
          inserted_at: ~U[2023-08-15T00:00:00.911400Z]
        )

      %{id: third_transaction_id} =
        insert!(:transaction,
          amount: 40_00,
          sender_id: account_id,
          inserted_at: ~U[2023-08-27T00:00:00.911400Z]
        )

      response =
        conn
        |> put_authorization(user)
        |> get(~p"/api/v1/transactions", attrs)
        |> json_response(200)

      assert %{
               "transcations" => [
                 %{
                   "amount" => 2000,
                   "id" => ^first_transaction_id,
                   "recipient_id" => _,
                   "sender_id" => ^account_id
                 },
                 %{
                   "amount" => 3000,
                   "id" => ^second_transaction_id,
                   "recipient_id" => _,
                   "sender_id" => ^account_id
                 },
                 %{
                   "amount" => 4000,
                   "id" => ^third_transaction_id,
                   "recipient_id" => _,
                   "sender_id" => ^account_id
                 }
               ]
             } = response
    end

    test "renders empty transaction list when no transaction are found", %{conn: conn} do
      user = %{account_id: account_id} = insert!(:user_with_account)

      insert!(:transaction,
        amount: 20_00,
        sender_id: account_id,
        inserted_at: ~U[2023-10-01T00:00:00.911400Z]
      )

      attrs = %{
        "start_date" => "2023-08-01T00:00:00.911400Z",
        "end_date" => "2023-08-30T00:00:00.911400Z"
      }

      response =
        conn
        |> put_authorization(user)
        |> get(~p"/api/v1/transactions", attrs)
        |> json_response(200)

      assert %{"transcations" => []} = response
    end

    test "renders error when token is missing from request", %{conn: conn} do
      attrs = %{
        "start_date" => "2023-08-01T00:00:00.911400Z",
        "end_date" => "2023-08-30T00:00:00.911400Z"
      }

      response =
        conn
        |> get(~p"/api/v1/transactions", attrs)
        |> json_response(401)

      assert response == %{
               "errors" =>
                 "An authorized JWT must be provided within the authorization header using the Bearer realm.",
               "message" => "Unauthorized"
             }
    end
  end
end

