defmodule MiniLand.Promotions do
  alias MiniLand.Repo
  alias MiniLand.Schema.Promotion

  def get_promotion_by_name(promotion_name) do
    Repo.get_by(Promotion, name: promotion_name)
  end

end
