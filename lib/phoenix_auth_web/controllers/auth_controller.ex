defmodule PhoenixAuthWeb.AuthController do
  use PhoenixAuthWeb, :controller

  def index(conn, _params) do
    conn
    |> render("ack.json", %{success: true, message: "hello there"})
  end
end