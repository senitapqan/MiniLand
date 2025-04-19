defmodule MiniLand.Orders do
  alias MiniLand.Auth.User
  alias MiniLand.Promotions
  alias MiniLand.Render.OrderJson
  alias MiniLand.Repo
  alias MiniLand.Schema.Order
  alias MiniLand.Users

  import Ecto.Query
  import Ecto.Changeset

  def create_order(attrs) do
    %Order{}
    |> change(attrs)
    |> Repo.insert()
  end

  def get_order!(id) do
    Repo.get!(Order, id)
  end

  def create_new_order(attrs) do
    promotion = Promotions.get_promotion_by_name(attrs.promotion_name)
    duration = promotion.duration

    start_time = DateTime.truncate(DateTime.utc_now(), :second)

    create_order(%{
      child_full_name: attrs.child_full_name,
      child_age: attrs.child_age,
      parent_full_name: attrs.parent_full_name,
      parent_phone: attrs.parent_phone,
      cost: promotion.cost,
      penalty: promotion.penalty,
      start_time: start_time,
      end_time: DateTime.add(start_time, duration, :minute),
      promotion_id: promotion.id,
      user_id: attrs.user_id
    })
    |> case do
      {:ok, order} ->
        {:ok, OrderJson.render_order(order)}

      {:error, _error} ->
        {:error, :unknown_error}
    end
  end

  def pull_orders(user_id, opts \\ []) do
    user = Users.get_user!(user_id)

    orders =
      pull_orders_query(user, opts)
      |> Repo.all()
      |> Enum.map(&OrderJson.render_order/1)

    {:ok, orders}
  end

  defp pull_orders_query(user, opts) do
    status = Keyword.get(opts, :status)
    from = Keyword.get(opts, :from)
    to = Keyword.get(opts, :to)

    Order
    |> base_query(user)
    |> filter_by_status(status)
    |> filter_by_start_time(from, to)
  end

  defp base_query(queryable, nil), do: queryable

  defp base_query(queryable, %User{role: "admin"}), do: queryable

  defp base_query(queryable, %User{role: "manager", id: user_id}) do
    from o in queryable, where: o.user_id == ^user_id
  end

  defp filter_by_status(query, nil), do: query

  defp filter_by_status(query, status) do
    from o in query, where: o.status == ^status
  end

  defp filter_by_start_time(query, nil, nil), do: query

  defp filter_by_start_time(query, from, nil) do
    from o in query, where: o.start_time >= ^from
  end

  defp filter_by_start_time(query, nil, to) do
    from o in query, where: o.start_time <= ^to
  end

  defp filter_by_start_time(query, from, to) do
    from o in query, where: o.start_time >= ^from and o.start_time <= ^to
  end

  def finish_order(order_id, user_id) do
    user = Users.get_user!(user_id)
    order = get_order!(order_id)

    if user.role == "admin" or order.user_id == user_id do
      get_order!(order_id)
      |> change(%{status: "finished"})
      |> Repo.update()

      {:ok, :finished}
    else
      {:error, :no_permission}
    end
  end

  def pull_order(order_id, user_id) do
    user = Users.get_user!(user_id)
    order = get_order!(order_id)

    if user.role == "admin" or order.user_id == user_id do
      order = OrderJson.render_order(order)
      {:ok, order}
    else
      {:error, :no_permission}
    end
  end
end
