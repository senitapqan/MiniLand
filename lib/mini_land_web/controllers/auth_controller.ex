defmodule MiniLandWeb.AuthController do
  use MiniLandWeb, :controller

  alias MiniLand.Auth

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

  defmodule SignUpContract do
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

  def sign_up(conn, unsafe_params) do
    with {:ok, params} <- SignUpContract.conform(unsafe_params) do
      case Auth.sign_up(params) do
        {:ok, user_id} ->
          json(conn, %{user_id: user_id})

        {:error, error} ->
          json(conn, %{error: error})
      end
    end
  end
end
