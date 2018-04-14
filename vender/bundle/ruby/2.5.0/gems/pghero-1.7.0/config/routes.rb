PgHero::Engine.routes.draw do
  scope "(:database)", constraints: proc { |req| (PgHero.config["databases"].keys + [nil]).include?(req.params[:database]) } do
    get "index_usage", to: "home#index_usage"
    get "space", to: "home#space"
    get "live_queries", to: "home#live_queries"
    get "queries", to: "home#queries"
    get "system", to: "home#system"
    get "cpu_usage", to: "home#cpu_usage"
    get "connection_stats", to: "home#connection_stats"
    get "replication_lag_stats", to: "home#replication_lag_stats"
    get "load_stats", to: "home#load_stats"
    get "explain", to: "home#explain"
    get "tune", to: "home#tune"
    get "connections", to: "home#connections"
    get "maintenance", to: "home#maintenance"
    post "kill", to: "home#kill"
    post "kill_long_running_queries", to: "home#kill_long_running_queries"
    post "kill_all", to: "home#kill_all"
    post "enable_query_stats", to: "home#enable_query_stats"
    post "explain", to: "home#explain"
    post "reset_query_stats", to: "home#reset_query_stats"

    # legacy routes
    get "system_stats" => redirect("system")
    get "query_stats" => redirect("queries")
    get "indexes" => redirect("index_usage")

    root to: "home#index"
  end
end
