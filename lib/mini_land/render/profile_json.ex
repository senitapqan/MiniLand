defmodule MiniLand.Render.ProfileJson do
  def render_profile(user) do
    %{
      id: user.id,
      full_name: user.full_name,
      phone: user.phone,
      username: user.username,
      role: user.role,
      status: user.status,
      hired_date: DateTime.to_date(user.inserted_at),
      fired_date: get_fired_date(user)
    }
  end

  defp get_fired_date(user) do
    if user.status == "inactive" do
      DateTime.to_date(user.updated_at)
    else
      nil
    end
  end
end
