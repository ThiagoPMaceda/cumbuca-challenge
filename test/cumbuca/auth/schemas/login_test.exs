defmodule Cumbuca.Accounts.Schemas.LoginTest do
  use Cumbuca.DataCase, async: true

  alias Cumbuca.Auth.Schemas.Login

  describe "changeset/2" do
    test "with valid data returns valid changeset" do
      attrs = %{cpf: "34645544063", password: "a1b4$%2b"}

      changeset = Login.changeset(%Login{}, attrs)

      assert changeset.valid?
      assert changeset.changes == attrs
    end

    test "with invalid data returns error changeset" do
      changeset = Login.changeset(%Login{}, %{})

      refute changeset.valid?

      assert errors_on(changeset) == %{cpf: ["can't be blank"], password: ["can't be blank"]}
    end
  end
end
