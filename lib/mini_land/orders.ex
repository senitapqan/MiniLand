defmodule MiniLand.Orders do
  alias MiniLand.Parser.OrderParser
  alias MiniLand.Promotions
  alias MiniLand.Repo
  alias MiniLand.Schema.Order
  alias MiniLand.Users

  require Ecto.Query
  import Ecto.Changeset

  def create_order!(attrs) do
    %Order{}
    |> change(attrs)
    |> Repo.insert!()
  end

  def get_order!(id) do
    Repo.get!(Order, id)
  end

  def create_new_order(attrs) do
    promotion = Promotions.get_promotion_by_name(attrs.promotion_name)
    duration = promotion.duration

    attrs =
      attrs
      |> Map.put(:start_time, DateTime.truncate(DateTime.utc_now(), :second))
      |> Map.put(:end_time, DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), duration, :second))
      |> Map.put(:promotion_id, promotion.id)
      |> Map.put(:cost, promotion.cost)
      |> Map.delete(:promotion_name)

    create_order!(attrs)
  end

  def pull_orders(user_id, status) do
    case status do
      nil -> Ecto.Query.from(o in Order, where: o.user_id == ^user_id)
      status -> Ecto.Query.from(o in Order, where: o.user_id == ^user_id and o.status == ^status)
    end
    |> Repo.all()
    |> Enum.map(&OrderParser.parse_order/1)
  end

  def finish_order(order_id, user_id) do
    user = Users.get_user!(user_id)
    order = get_order!(order_id)

    if user.role == "admin" or order.user_id == user_id do
      get_order!(order_id)
      |> change(%{status: "finished"})
      |> Repo.update!()
    else
      {:error, :no_permission}
    end
  end

  def pull_order(order_id, user_id) do
    user = Users.get_user!(user_id)
    order = get_order!(order_id)

    if user.role == "admin" or order.user_id == user_id do
      order = OrderParser.parse_order(order)
      {:ok, order}
    else
      {:error, :no_permission}
    end
  end
end
