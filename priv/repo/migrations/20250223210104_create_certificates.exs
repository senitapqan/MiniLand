defmodule MiniLand.Repo.Migrations.CreateCertificates do
  use Ecto.Migration

  def change do
    create table(:certificates) do
      add :buyer_full_name, :string, null: false
      add :buyer_phone, :string, null: false
      add :receiver_full_name, :string, null: false
      add :receiver_phone, :string, null: false
      add :status, :string, null: false
      add :cost, :integer, null: false

      add :promotion_id, references(:promotions, on_delete: :nilify_all), null: false

      timestamps()
    end
  end
end
