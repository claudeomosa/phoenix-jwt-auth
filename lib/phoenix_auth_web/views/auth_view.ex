defmodule PhoenixAuthWeb.AuthView do
  use PhoenixAuthWeb, :view

  def render("ack.json", %{success: success, message: message}), do: %{success: success, message: message}
  def render("errors.json", %{errors: errors}), do: %{success: false, errors: errors}
  def render("error.json", %{error: error}), do: %{success: false, error: error}
  def render("login.json",  %{success: success, message: message, token: token}), do:  %{success: success, message: message, token: token}
  def render("data.json", %{data: data}), do: %{success: true, data: data}

end