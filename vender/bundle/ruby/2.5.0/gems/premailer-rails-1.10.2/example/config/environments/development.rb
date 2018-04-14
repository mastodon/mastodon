Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.assets.debug = true
  config.assets.digest = true
  config.assets.raise_runtime_errors = true
end
