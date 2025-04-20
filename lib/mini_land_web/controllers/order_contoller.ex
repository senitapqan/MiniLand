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
      render_response(conn, Orders.create_new_order(params))
    end
  end

  def get_orders(conn, _params) do
    status = conn.params["status"]
    from = format_date(conn.params["from"], nil)
    to = format_date(conn.params["to"], nil)

    opts = [status: status, from: from, to: to]
    render_response(conn, Orders.pull_orders(conn.assigns.user_id, opts))
  end

  def finish_order(conn, _params) do
    order_id = conn.params["id"]
    render_response(conn, Orders.finish_order(order_id, conn.assigns.user_id))
  end

  def get_order(conn, _params) do
    order_id = conn.params["id"]

    render_response(conn, Orders.pull_order(order_id, conn.assigns.user_id))
  end

  defp format_date(nil, default), do: default

  defp format_date(date, _) do
    {:ok, data, _} = DateTime.from_iso8601(date)
    data
  end

  defp render_response(conn, response) do
    case response do
      {:ok, data} ->
        json(conn, %{data: data})

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{msg: "Order not found"})

      {:error, :no_permission} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You have no permission to access this order"})

      {:error, _error} ->
        conn
        |> put_status(500)
        |> json(%{msg: "Some unknown internal server error"})
    end
  end
end
