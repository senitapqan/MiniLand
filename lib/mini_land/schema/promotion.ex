defmodule MiniLand.Schema.Promotion do
  use MiniLand.Schema

  schema "promotions" do
    field :name, :string
    field :cost, :integer
    field :duration, :integer #minutes
    field :penalty, :integer #tenge per 30 minutes

    field :status, :string, default: "active"

    timestamps()
  end
end
