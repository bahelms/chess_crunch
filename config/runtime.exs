import Config

if config_env() == :prod do
  port = System.get_env("PORT", "80")

  config :chess_crunch, ChessCrunchWeb.Endpoint,
    http: [
      port: String.to_integer(port),
      transport_options: [socket_opts: [:inet6]]
    ],
    url: [host: System.get_env("HOST"), port: port],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
    server: true

  config :chess_crunch, ChessCrunch.Repo,
    ssl: true,
    url: System.fetch_env!("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))
end
