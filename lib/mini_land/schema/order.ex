defmodule MiniLand.Schema.Order do
  use MiniLand.Schema

  alias MiniLand.Auth.User
  alias MiniLand.Schema.Promotion

  schema "orders" do
    field :order_type, :string, default: "default"
    field :status, :string, default: "active"

    field :child_full_name, :string
    field :child_age, :integer
    field :parent_full_name, :string
    field :parent_phone, :string

    field :cost, :integer
    field :penalty, :integer, default: 0

    field :start_time, :utc_datetime
    field :end_time, :utc_datetime

    belongs_to :promotion, Promotion, foreign_key: :promotion_id
    belongs_to :user, User, foreign_key: :user_id
    timestamps()
  end
end
