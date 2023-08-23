defmodule Cumbuca.Auth.Token do
  def check_password(user, password), do: Argon2.check_pass(user, password)

  def hash_password(password), do: Argon2.add_hash(password)
end
