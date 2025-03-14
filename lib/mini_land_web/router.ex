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

    post "/sign_in", MiniLandWeb.AuthController, :sign_in
    post "/sign_up", MiniLandWeb.AuthController, :sign_up
  end

  scope "/manager" do
    pipe_through [:api, :authenticate]

    get "/orders", MiniLandWeb.OrderController, :get_orders
    get "/order/:id", MiniLandWeb.OrderController, :get_order
    post "/order", MiniLandWeb.OrderController, :create_order
    post "/order/finish/:id", MiniLandWeb.OrderController, :finish_order

    post "/certificate", MiniLandWeb.CertificateController, :create_certificate
    post "/certificate/use", MiniLandWeb.CertificateController, :use_certificate
    get "/certificate", MiniLandWeb.CertificateController, :get_certificates
    get "/certificate/search", MiniLandWeb.CertificateController, :search_certificate
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
