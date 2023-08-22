defmodule CumbucaWeb.Plugs.Authentication do
  use Guardian.Plug.Pipeline,
    otp_app: :cumbuca,
    module: CumbucaWeb.Guardian,
    error_handler: CumbucaWeb.FallbackController

  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end
