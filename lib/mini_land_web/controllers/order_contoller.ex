defmodule MiniLandWeb.OrderController do
  alias MiniLand.Orders
  use MiniLandWeb, :controller

  defmodule CreateOrderContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:order_type) => string(:filled?),
        required(:promotion_name) => string(:filled?),
        required(:child_full_name) => string(:filled?),
        required(:child_age) => integer(),
        required(:parent_full_name) => string(:filled?),
        required(:parent_phone) => string(:filled?)
      }
    end
  end

  def create_order(conn, params) do
    with {:ok, params} <- CreateOrderContract.conform(params) do
      params = Map.put(params, :user_id, conn.assigns.user_id)
      order = Orders.create_new_order(params)

      json(conn, %{order_id: order.id})
    end
  end

  def get_orders(conn, _params) do
    status = conn.params["status"]
    from = conn.params["from"]
    to = conn.params["to"]

    from = if from, do: Date.from_iso8601!(from), else: nil
    to = if to, do: Date.from_iso8601!(to), else: nil

    opts = [status: status, from: from, to: to]
    json(conn, Orders.pull_orders(conn.assigns.user_id, opts))
  end

  def finish_order(conn, _params) do
    order_id = conn.params["id"]

    case Orders.finish_order(order_id, conn.assigns.user_id) do
      :ok ->
        json(conn, %{message: "Order finished"})

      {:error, :no_permission} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You have no permission to finish this order"})
    end
  end

  def get_order(conn, _params) do
    order_id = conn.params["id"]

    case Orders.pull_order(order_id, conn.assigns.user_id) do
      {:ok, order} ->
        json(conn, order)

      {:error, :no_permission} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You have no permission to access this order"})
    end
  end
end
