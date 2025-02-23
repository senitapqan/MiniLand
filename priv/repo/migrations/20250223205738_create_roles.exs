defmodule MiniLand.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :role, :string, null: false
    end
  end
end
