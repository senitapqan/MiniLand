defmodule MiniLandWeb.AuthTest do
  use MiniLandWeb.ConnCase, async: true

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
      assert json_response(response, 401) == %{"error" => "Invalid credentials"}
    end
  end
end
