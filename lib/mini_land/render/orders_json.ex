defmodule MiniLand.Render.OrderJson do
  alias MiniLand.Repo
  alias MiniLand.Schema.Promotion

  def render_order(order) do
    promotion = Repo.get!(Promotion, order.promotion_id)

    %{
      id: order.id,
      order_type: order.order_type,
      promotion_name: promotion.name,
      child_full_name: order.child_full_name,
      child_age: order.child_age,
      parent_full_name: order.parent_full_name,
      parent_phone: order.parent_phone,
      order_date: DateTime.to_date(order.inserted_at),
      order_time: DateTime.to_time(order.inserted_at),
      status: order.status,
      cost: order.cost,
      penalty: order.penalty
    }
  end
end
