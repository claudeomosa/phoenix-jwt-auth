defmodule PhoenixAuthWeb.AuthController do
  use PhoenixAuthWeb, :controller
  alias PhoenixAuth.Accounts
  alias PhoenixAuth.Accounts.User
  alias PhoenixAuthWeb.Utils
  alias PhoenixAuth.AuthTokens
  alias PhoenixAuth.AuthTokens.AuthToken
  alias PhoenixAuth.Repo
  import Plug.Conn
  import Ecto.Query, warn: false
  import Joken

  def index(conn, _params) do
    conn
    |> render("ack.json", %{success: true, message: "hello there"})
  end

  def register(conn, params) do
    case Accounts.create_user(params) do
      {:ok, _user} -> conn
                     |> render("ack.json", %{success: true, message: "new user registered"})
      {:error, %Ecto.Changeset{} = changeset} -> conn
                                                 |> render("errors.json", %{ errors: Utils.format_changeset_errors(changeset)})
      _ -> conn
           |> render("error.json", %{ error: Utils.internal_server_error()})

    end
  end

  def login(conn, params) do
    %{"username" => username, "password" => password} = params
    with %User{} = user <- Accounts.get_user_by_username(username),
         true <- Pbkdf2.verify_pass(password, user.password) do
      signer = Joken.Signer.create("HS256", "LrdMlz1Tf+f97KqVMF60lQnZjE81qawZmGJl9oVw06/DgjTWivaIlXwm2FkSAMRg")

      extra_claims = %{"user_id" => user.id}
      {:ok, token, _claims} = PhoenixAuthWeb.JwtToken.generate_and_sign(extra_claims, signer)
      IO.inspect("#token #{token}")
      with {:ok, _claims} <- PhoenixAuthWeb.JwtToken.verify_and_validate(token, signer) do
        conn
        |> render("login.json", %{success: true, message: "successfully logged in", token: token})
      end
    else
      _ ->
        conn
        |> render("error.json", %{ error: Utils.invalid_credentials()})
    end
  end

  def get(conn, _params) do
#    IO.inspect(conn)
    conn
    |> render("data.json", %{data: conn.assigns.current_user} )
  end

  def delete(conn, _params) do
    case Ecto.build_assoc(conn.assigns.current_user, :auth_tokens, %{token: get_token(conn)}) |> Repo.insert!() do
      %AuthToken{} -> conn
                      |> render("ack.json", %{success: true, message: "user successfully logged out"})
      _ -> conn
           |> render("error.json", %{error: Utils.internal_server_error()})
    end

  end

  defp get_token(conn) do
     bearer = get_req_header(conn, "authorization")
              |> List.first()
     if bearer == nil do
        ""
     else
        bearer |> String.split(" ") |> List.last()
  end
end
end