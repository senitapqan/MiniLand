defmodule MiniLand.Auth.User do
  use MiniLand.Schema

  import Ecto.Changeset

  schema "users" do
    field :full_name, :string
    field :phone, :string
    field :photo_url, :string
    field :username, :string
    field :password, :string
    field :role, :string, default: "manager"
    field :status, :string, default: "active"

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:full_name, :phone, :photo_url, :username, :password, :role, :status, :inserted_at, :updated_at])
    |> validate_required([:full_name, :phone, :photo_url, :username, :password, :role, :status])
    |> unique_constraint(:username, name: :users_username_index)
    |> unique_constraint(:phone, name: :users_phone_index)
  end
end
