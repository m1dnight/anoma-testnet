defmodule AnomaWeb.HomeController do
  use AnomaWeb, :controller

  action_fallback AnomaWeb.FallbackController

  def index(conn, _params) do
    conn
    |> fetch_session()
    |> put_session(:user_id, 1)
    |> redirect(to: "/index.html")
  end
end
