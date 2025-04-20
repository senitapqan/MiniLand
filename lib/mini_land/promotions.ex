defmodule MiniLand.Promotions do
  alias MiniLand.Render.PromotionJson
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
    |> Promotion.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, promotion} ->
        {:ok, PromotionJson.render_promotion(promotion)}

      {:error, %Ecto.Changeset{errors: [name: {"has already been taken", _}]}} ->
        {:error, :duplicate_promotion}

      {:error, error} ->
        {:error, error}
    end
  end

  def pull_promotions() do
    promotions =
      Repo.all(Promotion)
      |> Enum.filter(&(&1.status == "active"))
      |> Enum.map(&PromotionJson.render_promotion/1)

    {:ok, promotions}
  end

  def delete_promotion(promotion_id) do
    promotion = get_promotion(promotion_id)

    if promotion do
      promotion
      |> change(%{status: "inactive"})
      |> Repo.update()

      {:ok, :deleted}
    else
      {:error, :not_found}
    end
  end
end
