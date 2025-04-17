defmodule MiniLand.Orders do
  alias MiniLand.Render.OrderJson
  alias MiniLand.Auth.User
  alias MiniLand.Promotions
  alias MiniLand.Repo
  alias MiniLand.Schema.Order
  alias MiniLand.Users

  require Ecto.Query
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

    %{
      start_time: start_time,
      end_time: DateTime.add(start_time, duration, :minute),
      promotion_id: promotion.id,
      cost: promotion.cost,
      penalty: attrs.penalty,
      duration: attrs.duration
    }
    |> create_order()
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

  defp maybe_admin_query(query, %User{role: "manager", id: user_id}),
    do: Ecto.Query.where(query, [o], o.user_id == ^user_id)

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
