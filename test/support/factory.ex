defmodule MiniLand.Factory do
  use ExMachina.Ecto, repo: MiniLand.Repo

  alias MiniLand.Auth.User
  alias MiniLand.Schema.Certificate
  alias MiniLand.Schema.Promotion

  defdelegate sequence(name), to: ExMachina

  def user_factory do
    %User{
      username: sequence(:username, &"username-#{&1}@example.com"),
      password: Bcrypt.hash_pwd_salt("qwerty"),
      full_name: sequence(:full_name, &"Full Name #{&1}"),
      photo_url: sequence(:photo_url, &"https://example.com/photo-#{&1}.jpg"),
      phone: sequence(:phone, &"#{&1}"),
      role: "manager",
      status: "active"
    }
  end

  def certificate_factory do
    %Certificate{
      buyer_full_name: sequence(:buyer_full_name, &"Buyer Full Name #{&1}"),
      buyer_phone: sequence(:buyer_phone, &"Buyer Phone #{&1}"),
      receiver_full_name: sequence(:receiver_full_name, &"Receiver Full Name #{&1}"),
      receiver_phone: sequence(:receiver_phone, &"Receiver Phone #{&1}"),
      status: "active",
      cost: 100,
      promotion: build(:promotion)
    }
  end

  def promotion_factory do
    %Promotion{
      name: sequence(:name, &"Promotion #{&1}"),
      cost: 100,
      duration: 30,
      status: "active"
    }
  end
end
