#!/bin/sh
set -e

echo "==> Running migrations..."
bin/mini_land eval "Ecto.Migrator.with_repo(MiniLand.Repo, &Ecto.Migrator.run(&1, :up, all: true))"

echo "==> Running seeds..."
bin/mini_land eval "Ecto.Migrator.with_repo(MiniLand.Repo, fn _ -> Code.eval_file(\"./priv/repo/seeds.exs\") end)"

echo "==> Starting Phoenix server..."
exec bin/mini_land start
