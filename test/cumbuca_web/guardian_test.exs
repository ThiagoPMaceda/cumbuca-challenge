defmodule CumbucaWeb.GuardianTest do
  use Cumbuca.DataCase, async: true

  alias Cumbuca.Accounts.Schemas.User
  alias CumbucaWeb.Guardian

  describe "subject_for_token/2" do
    test "return subject to create token" do
      user_id = UUID.generate()

      assert Guardian.subject_for_token(%User{id: user_id}) == {:ok, user_id}
    end

    test "just accept authentication struct" do
      assert Guardian.subject_for_token(%{id: "valid_id"}) ==
               {:error, :user_struct_not_given}
    end
  end

  describe "resource_from_claims/1" do
    test "return an user with permissions from sub claim" do
      %{id: user_id} = insert!(:user_with_account)

      claims = %{"sub" => user_id}

      assert {:ok, %User{id: ^user_id}} = Guardian.resource_from_claims(claims)
    end

    test "user not found" do
      claims = %{"sub" => UUID.generate()}

      assert Guardian.resource_from_claims(claims) == {:error, :user_not_found}
    end

    test "claims without sub key" do
      assert Guardian.resource_from_claims(%{}) == {:error, :sub_key_missing}
    end
  end
end
