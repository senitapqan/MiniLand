defmodule MiniLand.Users do
  use MiniLand.Schema

  alias MiniLand.Orders
  alias MiniLand.Auth.User
  alias MiniLand.Parser.ProfileParser
  alias MiniLand.Repo

  import Ecto.Changeset
  require Ecto.Query

  def create_user(attrs) do
    %User{}
    |> change(attrs)
    |> Repo.insert()
  end

  def create_user!(attrs) do
    %User{}
    |> change(attrs)
    |> Repo.insert!()
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def get_profile(user_id) do
    user = get_user!(user_id)
    ProfileParser.parse_profile(user)
  end

  def pull_managers() do
    Repo.all(User)
    |> Enum.filter(&(&1.role == "manager"))
    |> Enum.map(&ProfileParser.parse_profile/1)
  end

  def fire_manager(manager_id) do
    manager = get_user!(manager_id)

    case manager do
      nil ->
        {:error, "Manager not found"}

      _ ->
        manager
        |> change(%{status: "inactive"})
        |> Repo.update()

        :ok
    end
  end

  def restore_manager(manager_id) do
    manager = get_user!(manager_id)

    case manager do
      nil ->
        {:error, "Manager not found"}

      _ ->
        manager
        |> change(%{status: "active"})
        |> Repo.update()

        :ok
    end
  end

  def get_statistics(opts \\ []) do
    Ecto.Query.from(u in User, where: u.role == "manager")
    |> Repo.all()
    |> Enum.map(fn manager ->
      orders = Orders.pull_orders(manager.id, opts)
      {manager, orders}
     end)
    |> Enum.map(fn {manager, orders} ->
      ProfileParser.get_statistics(manager, orders)
    end)
  end
end
