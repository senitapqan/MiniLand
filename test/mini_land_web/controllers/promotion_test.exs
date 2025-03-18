defmodule MiniLandWeb.PromotionControllerTest do
  use MiniLandWeb.ConnCase, async: true

  alias MiniLand.Repo
  alias MiniLand.Schema.Promotion
  require Ecto.Query

  import MiniLand.Factory

  setup do
    admin = insert(:user, role: "admin")
    promotion = insert(:promotion)
    token = sign_in(admin)
    %{admin: admin, token: token, promotion: promotion}
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
    result["token"]
  end

  def get_promotions(token) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/admin/promotions")
  end

  describe "get promotions" do
    test "returns 200", %{token: token} do
      response = get_promotions(token)
      assert response.status == 200
    end

    test "returns 401" do
      response = get_promotions("fake_token")
      assert response.status == 401
    end

    test "returns all promotions", %{token: token} do
      response = get_promotions(token)
      assert response.resp_body |> Jason.decode!() |> length() == 1
    end
  end

  def create_promotion(token) do
    params = %{
      name: "test-promotion",
      cost: 100,
      duration: 30,
      penalty: 10
    }

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/admin/promotion/create", params)
  end

  describe "create promotion" do
    test "returns 200", %{token: token} do
      response = create_promotion(token)
      assert response.status == 200
    end

    test "returns 401" do
      response = create_promotion("fake_token")
      assert response.status == 401
    end

    test "creates a promotion", %{token: token} do
      create_promotion(token)
      assert Repo.exists?(Ecto.Query.from(p in Promotion, where: p.name == "test-promotion"))
    end
  end

  def delete_promotion(token, promotion_id) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/admin/promotion/delete/#{promotion_id}")
  end

  describe "delete promotion" do
    test "returns 200", %{token: token, promotion: promotion} do
      response = delete_promotion(token, promotion.id)
      assert response.status == 200
    end

    test "returns 401", %{promotion: promotion} do
      response = delete_promotion("fake_token", promotion.id)
      assert response.status == 401
    end

    test "deletes a promotion", %{token: token, promotion: promotion} do
      delete_promotion(token, promotion.id)
      promotion_id = promotion.id
      assert Repo.exists?(Ecto.Query.from(p in Promotion, where: p.id == ^promotion_id and p.status == "inactive"))
    end
  end
end
