defmodule CumbucaWeb.Guardian do
  use Guardian, otp_app: :cumbuca

  alias Cumbuca.Accounts.Schemas.User
  alias Cumbuca.Accounts

  def subject_for_token(user, claims \\ %{})
  def subject_for_token(%User{id: id}, _claims), do: {:ok, id}
  def subject_for_token(_user, _claims), do: {:error, :user_struct_not_given}

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user_by_id(id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :user_not_found}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :sub_key_missing}
  end
end
