defmodule PhoenixAuthWeb.JWTAuthPlug do
  alias PhoenixAuth.Accounts
  alias Accounts.User

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    bearer = get_req_header(conn, "authorization")
                  |> List.first()
    if bearer == nil do
      conn
      |> put_status(401) |> halt
    else
      token = bearer |> String.split(" ") |> List.last()
      signer = Joken.Signer.create("HS256", "LrdMlz1Tf+f97KqVMF60lQnZjE81qawZmGJl9oVw06/DgjTWivaIlXwm2FkSAMRg")

      with {:ok, %{"user_id" => user_id}} <- PhoenixAuthWeb.JwtToken.verify_and_validate(token, signer),
           %User{} = user <-Accounts.get_user(user_id) do

        conn
        |> assign(:current_user, user)
        else
          {:error, _reason} -> conn |> put_status(401) |> halt
          _ -> conn |> put_status(401) |> halt
      end
    end
  end
end