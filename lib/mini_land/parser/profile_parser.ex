defmodule MiniLand.Parser.ProfileParser do
  def parse_profile(user) do
    %{
      id: user.id,
      full_name: user.full_name,
      phone: user.phone,
      username: user.username
    }
  end
end
