defmodule CumbucaWeb.TransactionJSON do
  def index(%{transactions: transcations}) do
    %{transcations: for(transaction <- transcations, do: show(%{transaction: transaction}))}
  end

  def show(%{transaction: transaction}) do
    %{
      id: transaction.id,
      sender_id: transaction.sender_id,
      recipient_id: transaction.recipient_id,
      amount: transaction.amount
    }
  end

  def chargeback(%{transaction: transaction}) do
    %{
      id: transaction.id,
      sender_id: transaction.sender_id,
      recipient_id: transaction.recipient_id,
      amount: transaction.amount,
      chargeback: transaction.chargeback,
      chargeback_date: transaction.chargeback_date
    }
  end
end
