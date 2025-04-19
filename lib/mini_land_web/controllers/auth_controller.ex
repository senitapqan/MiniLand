defmodule MiniLandWeb.AuthController do
  use MiniLandWeb, :controller

  alias MiniLand.Auth
  alias MiniLand.Users

  defmodule SignInContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:username) => string(:filled?),
        required(:password) => string(:filled?)
      }
    end
  end

  def sign_in(conn, unsafe_params) do
    with {:ok, params} <- SignInContract.conform(unsafe_params) do
      render_response(
        conn,
        Auth.sign_in(%{
          username: params.username,
          password: params.password
        })
      )
    end
  end

  def get_profile(conn, _params) do
    user_id = conn.assigns.user_id
    render_response(conn, Users.get_profile(user_id))
  end

  def get_managers(conn, _params) do
    render_response(conn, Users.pull_managers())
  end

  def fire_manager(conn, _params) do
    manager_id = conn.params["id"]
    render_response(conn, Users.fire_manager(manager_id))
  end

  def restore_manager(conn, _params) do
    manager_id = conn.params["id"]
    render_response(conn, Users.restore_manager(manager_id))
  end

  def get_statistics(conn, _params) do
    status = "finished"
    from = format_date(conn.params["from"], DateTime.add(DateTime.utc_now(), -30, :day))
    to = format_date(conn.params["to"], DateTime.utc_now())

    opts = [status: status, from: from, to: to]
    render_response(conn, Users.get_statistics(opts))
  end

  defp format_date(nil, default), do: default

  defp format_date(date, _) do
    {:ok, data, _} = DateTime.from_iso8601(date)
    data
  end

  defmodule CreateManagerContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:password) => string(:filled?),
        required(:username) => string(:filled?),
        required(:phone) => string(:filled?),
        required(:full_name) => string(:filled?),
        required(:photo_url) => string(:filled?)
      }
    end
  end

  def create_manager(conn, unsafe_params) do
    with {:ok, params} <- CreateManagerContract.conform(unsafe_params) do
      render_response(conn, Auth.sign_up(params))
    end
  end

  defp render_response(conn, result) do
    case result do
      {:ok, result} ->
        json(conn, %{data: result})

      {:error, :username_already_taken} ->
        conn
        |> put_status(409)
        |> json(%{error: "Username already taken"})

      {:error, :phone_already_taken} ->
        conn
        |> put_status(409)
        |> json(%{error: "Phone already taken"})

      {:error, :invalid_credentials} ->
        conn
        |> put_status(401)
        |> json(%{error: "Invalid credentials"})

      {:error, :inactive_user} ->
        conn
        |> put_status(401)
        |> json(%{error: "Manager was fired"})

      {:error, _error} ->
        conn
        |> put_status(500)
        |> json(%{msg: "Some unknown internal server error"})
    end
  end
end
