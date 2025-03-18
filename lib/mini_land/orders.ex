defmodule MiniLand.Orders do
  alias MiniLand.Auth.User
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

    start_time = get_time()

    attrs =
      attrs
      |> Map.put(:start_time, start_time)
      |> Map.put(:end_time, DateTime.add(start_time, duration, :minute))
      |> Map.put(:promotion_id, promotion.id)
      |> Map.put(:cost, promotion.cost)
      |> Map.delete(:promotion_name)

    create_order!(attrs)
  end

  def pull_orders(user_id, opts \\ []) do
    user = Users.get_user!(user_id)

    pull_orders_query(user, opts)
    |> Repo.all()
    |> Enum.map(&OrderParser.parse_order/1)
  end

  defp pull_orders_query(user, opts) do
    status = Keyword.get(opts, :status, nil)
    from = Keyword.get(opts, :from, nil)
    to = Keyword.get(opts, :to, nil)

    Ecto.Query.from(o in Order)
    |> maybe_admin_query(user)
    |> maybe_add_status(status)
    |> maybe_add_from(from)
    |> maybe_add_to(to)
  end

  defp maybe_admin_query(query, nil), do: query
  defp maybe_admin_query(query, %User{role: "admin"}), do: query
  defp maybe_admin_query(query, %User{role: "manager", id: user_id}), do: Ecto.Query.where(query, [o], o.user_id == ^user_id)

  defp maybe_add_status(query, nil), do: query
  defp maybe_add_status(query, status), do: Ecto.Query.where(query, [o], o.status == ^status)

  defp maybe_add_from(query, nil), do: query
  defp maybe_add_from(query, from), do: Ecto.Query.where(query, [o], o.inserted_at >= ^from)
  defp maybe_add_to(query, nil), do: query
  defp maybe_add_to(query, to), do: Ecto.Query.where(query, [o], o.inserted_at <= ^to)


  def finish_order(order_id, user_id) do
    user = Users.get_user!(user_id)
    order = get_order!(order_id)

    if user.role == "admin" or order.user_id == user_id do
      get_order!(order_id)
      |> change(%{status: "finished"})
      |> Repo.update()

      :ok
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

  defp get_time() do
    {:ok, datetime} = DateTime.now(Application.get_env(:mini_land, :default_time_zone))
    DateTime.truncate(datetime, :second)
  end
end
