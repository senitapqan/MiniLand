defmodule MiniLandWeb.AuthTest do
  alias MiniLand.Auth.User
  use MiniLandWeb.ConnCase

  import MiniLand.Factory

  describe "sign in" do
    def do_request("sign_in") do
      params = %{
        username: "maskeugalievd@gmail.com",
        password: "qwerty"
      }

      build_conn()
      |> put_req_header("accept", "application/json")
      |> post("/auth/sign_in", params)
    end

    test "returns 200" do
      insert(:user, username: "maskeugalievd@gmail.com", password: Bcrypt.hash_pwd_salt("qwerty"))

      response = do_request("sign_in")

      {:ok, result} = Jason.decode(response.resp_body)
      assert json_response(response, 200) == result
    end

    test "response 401" do
      response = do_request("sign_in")
      assert json_response(response, 401) == %{"error" => "invalid_credentials"}
    end
  end

  describe "sign up" do
    def do_request("sign_up") do
      params = %{
        username: "test-user",
        password: "password",
        full_name: "test-name",
        photo_url: "test-photo-url",
        phone: "test-phone"
      }

      build_conn()
      |> put_req_header("accept", "application/json")
      |> post("/auth/sign_up", params)
    end

    test "returns 200" do
      response = do_request("sign_up")
      {:ok, result} = Jason.decode(response.resp_body)

      assert MiniLand.Repo.exists?(User)
      assert json_response(response, 200) == result
    end
  end
end
