defmodule MiniLand.Schema.Certificate do
  use MiniLand.Schema

  alias MiniLand.Schema.Promotion

  schema "certificates" do
    field :buyer_full_name, :string
    field :buyer_phone, :string
    field :receiver_full_name, :string
    field :receiver_phone, :string
    field :status, :string, default: "pending"
    field :cost, :integer

    belongs_to :promotion, Promotion

    timestamps()
  end
end
