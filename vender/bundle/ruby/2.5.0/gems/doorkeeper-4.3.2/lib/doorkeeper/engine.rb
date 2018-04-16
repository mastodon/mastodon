module Doorkeeper
  class Engine < Rails::Engine
    initializer "doorkeeper.params.filter" do |app|
      parameters = %w[client_secret code authentication_token access_token refresh_token]
      app.config.filter_parameters << /^(#{Regexp.union parameters})$/
    end

    initializer "doorkeeper.routes" do
      Doorkeeper::Rails::Routes.install!
    end

    initializer "doorkeeper.helpers" do
      ActiveSupport.on_load(:action_controller) do
        include Doorkeeper::Rails::Helpers
      end
    end

    if defined?(Sprockets) && Sprockets::VERSION.chr.to_i >= 4
      initializer 'doorkeeper.assets.precompile' do |app|
        app.config.assets.precompile += %w[
          doorkeeper/application.css
          doorkeeper/admin/application.css
        ]
      end
    end
  end
end
