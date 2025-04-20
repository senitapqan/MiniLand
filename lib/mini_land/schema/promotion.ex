defmodule MiniLand.Schema.Promotion do
  use MiniLand.Schema
  import Ecto.Changeset

  schema "promotions" do
    field :name, :string
    field :cost, :integer

    # minutes
    field :duration, :integer

    # tenge per 30 minutes
    field :penalty, :integer

    field :status, :string, default: "active"

    timestamps()
  end

  def changeset(promotion, attrs) do
    promotion
    |> cast(attrs, [:name, :cost, :duration, :penalty, :status, :inserted_at, :updated_at])
    |> unique_constraint(:name, name: :promotions_name_index)
  end
end
