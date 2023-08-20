defmodule Cumbuca.Guardian do
  use Guardian, otp_app: :cumbuca

  alias Cumbuca.Users.User
  alias Cumbuca.Users

  def subject_for_token(%User{cpf: cpf}, _claims), do: {:ok, cpf}
  def subject_for_token(_auth, _claims), do: {:error, :user_struct_not_found}

  def resource_from_claims(%{"sub" => cpf}) do
    resource = Users.get_user_by_cpf(cpf)
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
