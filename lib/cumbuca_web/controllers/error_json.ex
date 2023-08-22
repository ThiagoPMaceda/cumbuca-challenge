defmodule CumbucaWeb.ErrorJSON do
  def render("400.json", %{errors: errors}) do
    %{
      "message" => "Bad request",
      "errors" => errors
    }
  end

  def render("401.json", %{errors: errors}) do
    %{
      "message" => "Unauthorized",
      "errors" => errors
    }
  end

  def render("422.json", %{errors: errors}) do
    %{
      "message" => "Unprocessable entity",
      "errors" => errors
    }
  end

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
