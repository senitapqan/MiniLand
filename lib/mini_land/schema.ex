defmodule MiniLand.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @timestamps_opts [type: :utc_datetime, autogenerate: {MiniLand.Schema, :timestamp, []}]
    end
  end

  def timestamp do
    {:ok, dt} = DateTime.now("Asia/Qyzylorda")
    dt =DateTime.shift_zone!(dt, "Etc/UTC")
    DateTime.truncate(dt, :second)
  end
end
