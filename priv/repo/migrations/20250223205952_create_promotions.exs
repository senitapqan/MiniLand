defmodule MiniLand.Repo.Migrations.CreatePromotions do
  use Ecto.Migration

  def change do
    create table(:promotions) do
      add :name, :string, null: false
      add :cost, :integer, null: false
      add :duration, :integer, null: false
      add :penalty, :integer, null: false

      add :status, :string, null: false

      timestamps()
    end
  end
end
