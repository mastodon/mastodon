Rabl.configure do |config|
  config.cache_all_output  = true
  config.cache_sources     = !!Rails.env.production?
  config.include_json_root = false
  config.view_paths        = [Rails.root.join('app/views')]
end
