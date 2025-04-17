defmodule MiniLand.Schema.Promotion do
  use MiniLand.Schema

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
end
