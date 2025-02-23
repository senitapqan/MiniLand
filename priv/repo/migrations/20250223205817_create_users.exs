defmodule MiniLand.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password, :string, null: false
      add :username, :string, null: false

      add :avatar_url, :string
      add :name, :string, null: false
      add :surname, :string, null: false

      add :role_id, references(:roles, on_delete: :nilify_all), null: false
      add :status, :string, null: false

      timestamps()
    end
  end
end
