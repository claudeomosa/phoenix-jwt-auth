defmodule PhoenixAuthWeb.AuthView do
  use PhoenixAuthWeb, :view

  def render("ack.json", %{success: success, message: message}), do: %{success: success, message: message}
end