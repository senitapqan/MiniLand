defmodule MiniLand.Parser.PromotionParser do
  def parse_promotion(promotion) do
    %{
      id: promotion.id,
      name: promotion.name,
      cost: promotion.cost,
      duration: promotion.duration,
      penalty: promotion.penalty
    }
  end
end
