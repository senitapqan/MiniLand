defmodule MiniLandWeb.PromotionController do
  use MiniLandWeb, :controller

  alias MiniLand.Promotions

  def get_promotions(conn, _params) do
    json(conn, Promotions.pull_promotions())
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
      case Promotions.create_promotion(params) do
        {:ok, promotion} ->
          json(conn, %{promotion_id: promotion.id})

        {:error, error} ->
          json(conn, %{error: error})
      end
    end
  end

  def delete_promotion(conn, _params) do
    promotion_id = conn.params["id"]

    case Promotions.delete_promotion(promotion_id) do
      :ok ->
        json(conn, %{message: "Promotion disabled"})

      {:error, error} ->
        json(conn, %{error: error})
    end
  end
end
