defmodule MiniLandWeb.Router do
  use MiniLandWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticate do
    plug AppWeb.Plugs.Authenticate
  end

  scope "/auth" do
    pipe_through [:api]

    post "/sign_in", AppWeb.AuthController, :sign_in
    post "/sign_up", AppWeb.AuthController, :sign_up
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mini_land, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: MiniLandWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
