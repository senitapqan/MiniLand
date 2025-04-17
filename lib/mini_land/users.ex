defmodule MiniLand.Users do
  use MiniLand.Schema

  alias MiniLand.Auth.User
  alias MiniLand.Orders
  alias MiniLand.Render.ProfileJson
  alias MiniLand.Repo

  import Ecto.Changeset
  require Ecto.Query

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user!(attrs) do
    %User{}
    |> User.changeset(attrs)
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
    {:ok, ProfileJson.render_profile(user)}
  end

  def pull_managers() do
    managers =
      Repo.all(User)
      |> Enum.filter(&(&1.role == "manager"))
      |> Enum.map(&ProfileJson.render_profile/1)

    {:ok, managers}
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

        {:ok, :fired}
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

        {:ok, :restored}
    end
  end

  def get_statistics(opts \\ []) do
    managers =
      Ecto.Query.from(u in User, where: u.role == "manager" and u.status == "active")
      |> Repo.all()

    stats =
      Enum.map(managers, fn manager ->
        {:ok, orders} = Orders.pull_orders(manager.id, opts)

      total_earnings =
        Enum.reduce(orders, 0, fn order, acc ->
          acc + order.cost
        end)

      %{
        manager: ProfileJson.render_profile(manager),
        statistics: %{
          total_earnings: total_earnings,
          total_orders: length(orders)
        }
      }
    end)

    {:ok, stats}
  end
end
