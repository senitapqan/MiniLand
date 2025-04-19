defmodule MiniLandWeb.OrderTest do
  use MiniLandWeb.ConnCase, async: true

  alias MiniLand.Repo
  alias MiniLand.Schema.Order

  import MiniLand.Factory
  require Ecto.Query

  setup do
    promotion = insert(:promotion)
    user = insert(:user)
    order = insert(:order, %{user: user, promotion: promotion})
    token = sign_in(user)

    %{user: user, token: token, promotion: promotion, order: order}
  end

  def sign_in(user) do
    params = %{
      username: user.username,
      password: "qwerty"
    }

    response =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> post("/auth/sign_in", params)

    {:ok, result} = Jason.decode(response.resp_body)
    result["data"]["token"]
  end

  def get_orders(token) do
    query_string = URI.encode_query(%{status: "active"})

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/manager/orders?#{query_string}")
  end

  describe "get orders" do
    test "returns 200 status", %{token: token} do
      response = get_orders(token)

      assert response.status == 200
    end

    test "returns orders", %{token: token} do
      response = get_orders(token)

      assert response.status == 200
      dbg(Jason.decode!(response.resp_body))
    end
  end

  def finish_order(token, order_id) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/manager/order/finish/#{order_id}")
  end

  describe "finish order" do
    test "returns 200 status", %{token: token, order: order} do
      response = finish_order(token, order.id)

      assert response.status == 200
    end

    test "changes order status to finished", %{token: token, order: order} do
      finish_order(token, order.id)

      assert Repo.exists?(Ecto.Query.from(o in Order, where: o.id == ^order.id and o.status == "finished"))
    end
  end

  def create_order(token, params \\ %{}) do
    params =
      Map.merge(
        %{
          promotion_name: "promotion_name",
          order_type: "order_type",
          child_full_name: "child_full_name",
          child_age: 7,
          parent_full_name: "parent_full_name",
          parent_phone: "parent_phone"
        },
        params
      )

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/manager/order", params)
  end

  describe "create order" do
    test "returns 200 status", %{token: token, promotion: promotion} do
      response = create_order(token, %{promotion_name: promotion.name})

      assert response.status == 200
    end

    test "creates order", %{token: token, promotion: promotion} do
      create_order(token, %{promotion_name: promotion.name})

      assert Repo.exists?(Ecto.Query.from(o in Order, where: o.status == "active"))
    end
  end
end
