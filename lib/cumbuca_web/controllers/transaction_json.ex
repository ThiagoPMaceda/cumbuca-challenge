defmodule CumbucaWeb.TransactionJSON do
  def show(%{transaction: transaction}) do
    %{
      id: transaction.id,
      sender_id: transaction.sender_id,
      recipient_id: transaction.recipient_id,
      amount: transaction.amount
    }
  end
end
