defmodule MiniLand.Parser.OrderParser do
  alias MiniLand.Repo
  alias MiniLand.Schema.Promotion

  def parse_order(order) do
    promotion = Repo.get!(Promotion, order.promotion_id)

    %{
      id: order.id,
      order_type: order.order_type,
      promotion_name: promotion.name,
      child_full_name: order.child_full_name,
      child_age: order.child_age,
      parent_full_name: order.parent_full_name,
      parent_phone: order.parent_phone,
      status: order.status
    }
  end
end
