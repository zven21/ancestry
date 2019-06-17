use Mix.Config

config :ancestry, Dummy.Repo,
  username: "postgres",
  password: "postgres",
  database: "ancestry_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
