ActiveModelSerializers.config.tap do |config|
  config.default_includes = '**'
end

ActiveSupport::Notifications.unsubscribe(ActiveModelSerializers::Logging::RENDER_EVENT)
