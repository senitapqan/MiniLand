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
      case Auth.sign_in(%{username: params.username, password: params.password}) do
        {:ok, token} ->
          json(conn, %{token: token})

        {:error, error} ->
          conn
          |> put_status(:unauthorized)
          |> json(%{error: error})
      end
    end
  end

  def get_profile(conn, _params) do
    user_id = conn.params["id"]
    json(conn, Users.get_profile(user_id))
  end

  def get_managers(conn, _params) do
    json(conn, Users.pull_managers())
  end

  def fire_manager(conn, _params) do
    manager_id = conn.params["id"]

    case Users.fire_manager(manager_id) do
      :ok ->
        json(conn, %{message: "Manager fired"})

      {:error, error} ->
        json(conn, %{error: error})
    end
  end

  def restore_manager(conn, _params) do
    manager_id = conn.params["id"]

    case Users.restore_manager(manager_id) do
      :ok ->
        json(conn, %{message: "Manager restored"})

      {:error, error} ->
        json(conn, %{error: error})
    end
  end

  def get_statistics(conn, _params) do
    status = "active"
    from = conn.params["from"] || DateTime.add(DateTime.utc_now(), -30, :day)
    to = conn.params["to"] || DateTime.utc_now()

    opts = [status: status, from: from, to: to]
    json(conn, Users.get_statistics(opts))
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
      case Auth.sign_up(params) do
        {:ok, user_id} ->
          json(conn, %{user_id: user_id})

        {:error, error} ->
          json(conn, %{error: error})
      end
    end
  end
end
