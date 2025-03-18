defmodule MiniLandWeb.CertificateTest do
  use MiniLandWeb.ConnCase, async: true

  alias MiniLand.Repo
  alias MiniLand.Schema.Certificate
  alias MiniLand.Schema.Order

  import MiniLand.Factory
  require Ecto.Query

  setup do
    promotion = insert(:promotion)
    user = insert(:user)
    token = sign_in(user)

    %{user: user, token: token, promotion: promotion}
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

  def create_certificate(token, params \\ %{}) do
    params =
      Map.merge(
        %{
          buyer_full_name: "buyer_full_name",
          buyer_phone: "buyer_phone",
          receiver_full_name: "receiver_full_name",
          receiver_phone: "receiver_phone",
          promotion_name: "promotion_name"
        },
        params
      )

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/manager/certificate", params)
  end

  describe "create certificate" do
    test "creates a certificate", %{token: token, promotion: promotion} do
      response = create_certificate(token, %{promotion_name: promotion.name})

      assert Repo.exists?(Certificate)
      assert response.status == 201
    end
  end

  def use_certificate(token, params \\ %{}) do
    params =
      Map.merge(
        %{
          certificate_id: 47683,
          attrs: %{
            order_type: "order_type",
            promotion_name: "promotion_name",
            child_full_name: "child_full_name",
            child_age: 1,
            parent_full_name: "parent_full_name",
            parent_phone: "parent_phone"
          }
        },
        params,
        fn
          _k, v1, v2 when is_map(v1) -> Map.merge(v1, v2)
          _k, _v1, v2 -> v2
        end
      )

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/manager/certificate/use", params)
  end

  describe "use certificate" do
    test "uses a certificate", %{token: token, promotion: promotion} do
      certificate = insert(:certificate, %{promotion: promotion})

      response =
        use_certificate(
          token,
          %{
            certificate_id: certificate.id,
            attrs: %{
              promotion_name: promotion.name
            }
          }
        )

      assert Repo.exists?(Ecto.Query.from(c in Certificate, where: c.status == "used"))
      assert response.status == 200
    end

    test "creates order after using certificate", %{token: token, promotion: promotion} do
      certificate = insert(:certificate, %{promotion: promotion})

      response =
        use_certificate(
          token,
          %{
            certificate_id: certificate.id,
            attrs: %{
              promotion_name: promotion.name
            }
          }
        )

      assert Repo.exists?(Order)
      assert response.status == 200
    end
  end

  def get_certificates(token) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/manager/certificates")
  end

  describe "get certificates" do
    test "returns certificates", %{token: token} do
      insert(:certificate)
      response = get_certificates(token)

      assert response.status == 200
    end
  end
end
