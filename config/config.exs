use Mix.Config

config :logger, :console, level: :error

config :ancestry, ecto_repos: [Dummy.Repo]

import_config "#{Mix.env()}.exs"
