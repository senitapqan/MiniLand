defmodule MiniLand.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :password, :string, null: false
      add :username, :string, null: false
      add :phone, :string, null: false

      add :photo_url, :string
      add :full_name, :string, null: false

      add :role, :string, null: false
      add :status, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:username], name: :users_username_index)
    create unique_index(:users, [:phone], name: :users_phone_index)
  end
end
