defmodule AnomaWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use AnomaWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: AnomaWeb.ChangesetJSON)
    |> render(:error, changeset: changeset, success: false)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: AnomaWeb.ErrorHTML, json: AnomaWeb.ErrorJSON)
    |> render(:"401")
  end

  def call(conn, {:error, :user_already_claimed_invite}) do
    conn
    |> put_status(:unauthorized)
    |> assign(:error, "user already claimed invite")
    |> put_view(html: AnomaWeb.ErrorHTML, json: AnomaWeb.ErrorJSON)
    |> render(:"401")
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(:unauthorized)
    |> assign(:error, message)
    |> put_view(html: AnomaWeb.ErrorHTML, json: AnomaWeb.ErrorJSON)
    |> render(:"401")
  end
end
