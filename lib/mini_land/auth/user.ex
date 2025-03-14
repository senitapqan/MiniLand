defmodule MiniLand.Auth.User do
  use MiniLand.Schema

  schema "users" do
    field :full_name, :string
    field :phone, :string
    field :photo_url, :string
    field :username, :string
    field :password, :string
    field :role, :string, default: "user"
    field :status, :string, default: "active"

    timestamps()
  end
end
