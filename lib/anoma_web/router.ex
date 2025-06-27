defmodule AnomaWeb.Router do
  use AnomaWeb, :router

  pipeline :api do
    plug CORSPlug

    # plug CORSPlug, origin: ["http://localhost:5173", "http://localhost:4000", "https://anomaland.netlify.app"]
    plug :accepts, ["json"]
    plug :fetch_session
    plug OpenApiSpex.Plug.PutApiSpec, module: AnomaWeb.ApiSpec
  end

  # Authenticated API pipeline
  pipeline :authenticated_api do
    plug CORSPlug

    # plug CORSPlug, origin: ["http://localhost:5173", "http://localhost:4000", "https://anomaland.netlify.app"]
    plug :accepts, ["json"]
    plug AnomaWeb.Plugs.AuthPlug
  end

  scope "/" do
    pipe_through :api
    get "/", AnomaWeb.HomeController, :index

    scope "/openapi" do
      # serve the spec
      get "/", OpenApiSpex.Plug.RenderSpec, []
      # allow openapi to be rendered in the browser
      get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/openapi"
    end
  end

  # unauthenticated api routes
  # /api/v1
  scope "/api/v1", AnomaWeb.Api do
    pipe_through :api
    # trade a code and code_verifier for a token and user
    post "/user/auth", UserController, :auth
    # authenticate with MetaMask signature
    post "/user/metamask-auth", UserController, :metamask_auth
  end

  # authenticated api routes
  scope "/api/v1", AnomaWeb.Api do
    pipe_through :authenticated_api

    # /api/v1/user
    scope "/user" do
      post "/ethereum-address", UserController, :update_eth_address
      get "/daily-points", UserController, :daily_points
      post "/claim-daily-point", UserController, :claim_point
    end

    # /api/v1/fitcoin
    scope "/fitcoin" do
      post "/", FitcoinController, :add
      get "/balance", FitcoinController, :balance
    end

    # /api/v1/coupons
    scope "/coupons" do
      get "/", CouponController, :list
    end

    # /api/v1/invite
    scope "/invite" do
      get "/", InviteController, :list_invites
      put "/redeem/:invite_code", InviteController, :redeem_invite
    end
  end
end
