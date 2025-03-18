defmodule MiniLand.Promotions do
  alias MiniLand.Parser.PromotionParser
  alias MiniLand.Repo
  alias MiniLand.Schema.Promotion

  import Ecto.Changeset

  def get_promotion_by_name(promotion_name) do
    Repo.get_by(Promotion, name: promotion_name)
  end

  def get_promotion(promotion_id) do
    Repo.get(Promotion, promotion_id)
  end

  def create_promotion(attrs) do
    %Promotion{}
    |> change(attrs)
    |> Repo.insert()
  end

  def pull_promotions() do
    Repo.all(Promotion)
    |> Enum.map(&PromotionParser.parse_promotion/1)
  end

  def delete_promotion(promotion_id) do
    promotion = get_promotion(promotion_id)

    if promotion do
      promotion
      |> change(%{status: "inactive"})
      |> Repo.update()

      :ok
    else
      {:error, "Promotion not found"}
    end
  end
end
