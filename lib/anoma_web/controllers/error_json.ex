defmodule AnomaWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """
  def render("401.json", %{error: error}) do
    %{success: false, error: error}
  end

  def render("404.json", _) do
    %{success: false, error: "not found"}
  end

  def render("422.json", %{error: error}) do
    %{success: false, error: error}
  end

  def render("500.json", %{error: error}) do
    %{success: false, error: error}
  end

  def render(template, _assigns) do
    %{
      success: false,
      errors: %{detail: Phoenix.Controller.status_message_from_template(template)}
    }
  end
end
