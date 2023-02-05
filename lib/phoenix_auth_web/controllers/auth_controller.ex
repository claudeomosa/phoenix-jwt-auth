defmodule PhoenixAuthWeb.AuthController do
  use PhoenixAuthWeb, :controller
  alias PhoenixAuth.Accounts
  alias PhoenixAuth.Accounts.User
  alias PhoenixAuthWeb.Utils
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
      with {:ok, claims} <- PhoenixAuthWeb.JwtToken.verify_and_validate(token, signer) do
        conn
        |> render("login.json", %{success: true, message: "successfully logged in", token: token})
      end
    else
      _ ->
        conn
        |> render("error.json", %{ error: Utils.invalid_credentials()})
    end
  end

end