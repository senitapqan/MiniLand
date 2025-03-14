defmodule MiniLand.Schema.Promotion do
  use MiniLand.Schema

  schema "promotions" do
    field :name, :string
    field :cost, :integer
    field :duration, :integer
    field :status, :string

    timestamps()
  end
end
