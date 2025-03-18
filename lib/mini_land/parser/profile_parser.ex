defmodule MiniLand.Parser.ProfileParser do
  def parse_profile(user) do
    %{
      id: user.id,
      full_name: user.full_name,
      phone: user.phone,
      username: user.username,
      role: user.role,
      status: user.status,
      hired_date: DateTime.to_date(user.inserted_at),
      fired_date: get_fired_date(user)
    }
  end

  def get_statistics(user, orders) do
    %{
      total_orders: length(orders),
      total_orders_cost: Enum.reduce(orders, 0, fn order, acc -> acc + order.cost end),
      full_name: user.full_name,
    }
  end

  defp get_fired_date(user) do
    if user.status == "inactive" do
      DateTime.to_date(user.updated_at)
    else
      nil
    end
  end
end
