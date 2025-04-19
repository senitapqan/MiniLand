alias MiniLand.Auth.User
alias MiniLand.Repo
alias MiniLand.Schema.Promotion

defmodule MiniLand.Seeds do
  def run do
    load_admin()
    load_promotions()
  end

  defp load_admin() do
    File.read!("priv/repo/seeds/admin.json")
    |> Jason.decode!()
    |> insert_admin()
  end

  defp load_promotions() do
    File.read!("priv/repo/seeds/promotions.json")
    |> Jason.decode!()
    |> insert_promotions()
  end

  defp insert_admin(admin) do
    unless Repo.get_by(User,
             username: admin["username"],
             role: admin["role"],
             status: admin["status"],
             full_name: admin["full_name"],
             phone: admin["phone"],
             photo_url: admin["photo_url"]
           ) do
      %User{
        username: admin["username"],
        role: admin["role"],
        status: admin["status"],
        full_name: admin["full_name"],
        phone: admin["phone"],
        photo_url: admin["photo_url"],
        password: Bcrypt.hash_pwd_salt(admin["password"])
      }
      |> Repo.insert!()
    end
  end

  defp insert_promotions(promotions) do
    Enum.each(promotions, fn promotion ->
      unless Repo.get_by(Promotion,
               name: promotion["name"],
               cost: promotion["cost"],
               duration: promotion["duration"],
               penalty: promotion["penalty"],
               status: promotion["status"]
             ) do
        %Promotion{
          name: promotion["name"],
          cost: promotion["cost"],
          duration: promotion["duration"],
          penalty: promotion["penalty"],
          status: promotion["status"]
        }
        |> Repo.insert!()
      end
    end)
  end
end

MiniLand.Seeds.run()
