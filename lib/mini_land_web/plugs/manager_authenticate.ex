defmodule MiniLandWeb.Plugs.ManagerAuthenticate do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> get_auth_token()
    |> MiniLand.Auth.verify_token()
    |> case do
      {:ok, user_id, "manager"} ->
        assign(conn, :user_id, user_id)

      {:ok, _user_id, "admin"} ->
        conn
        |> put_status(403)
        |> json(%{error: "This endpoint is only available for managers"})
        |> halt()

      false ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        |> halt()
    end
  end

  defp get_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end
end
