defmodule MiniLandWeb.Router do
  use MiniLandWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :manager_authenticate do
    plug AppWeb.Plugs.ManagerAuthenticate
  end

  pipeline :admin_authenticate do
    plug AppWeb.Plugs.AdminAuthenticate
  end

  scope "/auth" do
    pipe_through [:api]

    # test done
    post "/sign_in", MiniLandWeb.AuthController, :sign_in

    # test done
    post "/sign_up", MiniLandWeb.AuthController, :sign_up
  end

  scope "/manager" do
    pipe_through [:api, :manager_authenticate]

    get "/", MiniLandWeb.AuthController, :get_profile

    # test done
    get "/orders", MiniLandWeb.OrderController, :get_orders

    # test done
    get "/order/:id", MiniLandWeb.OrderController, :get_order

    # test done
    post "/order", MiniLandWeb.OrderController, :create_order

    # test done
    post "/order/finish/:id", MiniLandWeb.OrderController, :finish_order

    # test done
    post "/certificate", MiniLandWeb.CertificateController, :create_certificate

    # test done
    post "/certificate/use", MiniLandWeb.CertificateController, :use_certificate
    post "/certificate/delete/:id", MiniLandWeb.CertificateController, :delete_certificate

    # test done
    get "/certificates", MiniLandWeb.CertificateController, :get_certificates
    get "/certificate/search", MiniLandWeb.CertificateController, :search_certificate
  end

  scope "/admin" do
    pipe_through [:api, :admin_authenticate]

    get "/", MiniLandWeb.AuthController, :get_statistics

    get "/managers", MiniLandWeb.AuthController, :get_managers
    post "/manager/fire/:id", MiniLandWeb.AuthController, :fire_manager
    post "/manager/restore/:id", MiniLandWeb.AuthController, :restore_manager
    post "/manager/create", MiniLandWeb.AuthController, :create_manager

    get "/orders", MiniLandWeb.OrderController, :get_orders

    get "/certificates", MiniLandWeb.CertificateController, :get_certificates
    get "/certificate/search", MiniLandWeb.CertificateController, :search_certificate

    get "/promotions", MiniLandWeb.PromotionController, :get_promotions
    post "/promotion/create", MiniLandWeb.PromotionController, :create_promotion
    post "/promotion/delete/:id", MiniLandWeb.PromotionController, :delete_promotion
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
