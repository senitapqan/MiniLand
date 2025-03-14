defmodule MiniLand.Repo.Migrations.CreateOrder do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :order_type, :string, null: false
      add :status, :string, null: false

      add :cost, :integer, null: false
      add :penalty, :integer, null: false

      add :child_full_name, :string, null: false
      add :parent_full_name, :string, null: false
      add :child_age, :integer, null: false
      add :parent_phone, :string, null: false

      add :start_time, :utc_datetime, null: false
      add :end_time, :utc_datetime, null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :promotion_id, references(:promotions, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
