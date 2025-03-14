defmodule MiniLand.Users do
  use MiniLand.Schema

  alias MiniLand.Auth.User
  alias MiniLand.Parser.ProfileParser
  alias MiniLand.Repo

  import Ecto.Changeset

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
end
