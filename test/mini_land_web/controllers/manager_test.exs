defmodule MiniLandWeb.ManagerControllerTest do
  use MiniLandWeb.ConnCase, async: true

  alias MiniLand.Auth.User
  alias MiniLand.Repo

  import MiniLand.Factory
  require Ecto.Query

  setup do
    admin = insert(:user, username: "admin", role: "admin")
    manager = insert(:user, role: "manager")
    token = sign_in(admin)
    %{token: token, manager: manager, admin: admin}
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

  def get_managers(token) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/admin/managers")
  end

  describe "get managers" do
    test "returns 200", %{token: token} do
      response = get_managers(token)
      assert response.status == 200
    end

    test "returns all managers", %{token: token} do
      response = get_managers(token)
      assert response.status == 200
      dbg(Jason.decode!(response.resp_body))
    end
  end

  def fire_manager(token, manager_id) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/admin/manager/fire/#{manager_id}")
  end

  describe "fire manager" do
    test "returns 200", %{manager: manager, token: token} do
      response = fire_manager(token, manager.id)
      assert response.status == 200
      dbg(Jason.decode!(response.resp_body))
    end

    test "returns 401", %{manager: manager} do
      response = fire_manager("fake_token", manager.id)
      assert response.status == 401
    end

    test "fires a manager", %{manager: manager, token: token} do
      fire_manager(token, manager.id)
      manager_id = manager.id
      assert Repo.exists?(Ecto.Query.from(u in User, where: u.id == ^manager_id and u.status == "inactive"))
    end
  end

  def restore_manager(token, manager_id) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/admin/manager/restore/#{manager_id}")
  end

  describe "restore manager" do
    test "returns 200", %{manager: manager, token: token} do
      response = restore_manager(token, manager.id)
      assert response.status == 200
    end

    test "returns 401", %{manager: manager} do
      response = restore_manager("fake_token", manager.id)
      assert response.status == 401
    end

    test "restores a manager", %{token: token} do
      manager = insert(:user, role: "manager", status: "inactive")
      manager_id = manager.id
      restore_manager(token, manager_id)
      assert Repo.exists?(Ecto.Query.from(u in User, where: u.id == ^manager_id and u.status == "active"))
    end
  end

  def create_manager(token) do
    params = %{
      username: "test-user",
      password: "password",
      full_name: "test-name",
      photo_url: "test-photo-url",
      phone: "test-phone"
    }

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/admin/manager/create", params)
  end

  describe "create manager" do
    test "returns 200", %{token: token} do
      response = create_manager(token)
      assert response.status == 200
    end

    test "returns 401" do
      response = create_manager("fake_token")
      assert response.status == 401
    end

    test "creates a manager", %{token: token} do
      create_manager(token)
      assert Repo.exists?(Ecto.Query.from(u in User, where: u.username == "test-user"))
    end
  end

  def get_statistics(token) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/admin/")
  end

  describe "get statistics" do
    test "returns 200", %{token: token} do
      response = get_statistics(token)
      assert response.status == 200
    end
  end
end
