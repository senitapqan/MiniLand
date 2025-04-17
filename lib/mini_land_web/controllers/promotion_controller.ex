defmodule MiniLandWeb.PromotionController do
  use MiniLandWeb, :controller

  alias MiniLand.Promotions

  def get_promotions(conn, _params) do
    promotions = Promotions.pull_promotions()
    render_response(conn, {:ok, promotions})
  end

  defmodule CreatePromotionContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:name) => string(:filled?),
        required(:cost) => integer(:filled?),
        required(:duration) => integer(:filled?),
        required(:penalty) => integer(:filled?)
      }
    end
  end

  def create_promotion(conn, unsafe_params) do
    with {:ok, params} <- CreatePromotionContract.conform(unsafe_params) do
      render_response(conn, Promotions.create_promotion(params))
    end
  end

  def delete_promotion(conn, _params) do
    promotion_id = conn.params["id"]
    render_response(conn, Promotions.delete_promotion(promotion_id))
  end

  defp render_response(conn, response) do
    case response do
      {:ok, data} ->
        json(conn, %{data: data})

      {:error, error} ->
        conn
        |> put_status(500)
        |> json(%{msg: "Some unknown internal server error", error: error})
    end
  end
end
