Rabl.configure do |config|
  config.json_engine       = Oj
  config.cache_all_output  = false
  config.cache_sources     = Rails.env.production?
  config.include_json_root = false
  config.view_paths        = [Rails.root.join('app/views')]
end
