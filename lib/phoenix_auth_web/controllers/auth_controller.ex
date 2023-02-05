defmodule PhoenixAuthWeb.AuthController do
  use PhoenixAuthWeb, :controller
  alias PhoenixAuth.Accounts
  alias PhoenixAuthWeb.Utils
  def index(conn, _params) do
    conn
    |> render("ack.json", %{success: true, message: "hello there"})
  end

  def register(conn, params) do
    case Accounts.create_user(params) do
      {:ok, _user} -> conn
                     |> render("ack.json", %{success: true, message: "new user registered"})
      {:error, %Ecto.Changeset{} = changeset} -> conn
                                                 |> render("errors.json", %{success: false, errors: Utils.format_changeset_errors(changeset)})
      _ -> conn
           |> render("error.json", %{success: false, error: Utils.internal_server_error()})

    end
  end

end