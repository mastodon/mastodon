ENV['RAILS_ENV'] ||= 'test'

require 'action_controller/railtie'
require 'simple_navigation'

module RailsApp
  class Application < Rails::Application
    config.active_support.deprecation = :log
    config.cache_classes = true
    config.eager_load = false
    config.root = __dir__
    config.secret_token = 'x'*100
    config.session_store :cookie_store, key: '_myapp_session'
  end

  class TestsController < ActionController::Base
    def base
      render inline: <<-END
        <!DOCTYPE html>
        <html>
          <body>
            <%= render_navigation %>
          </body>
        </html>
      END
    end
  end
end

Rails.backtrace_cleaner.remove_silencers!
RailsApp::Application.initialize!

RailsApp::Application.routes.draw do
  get '/base_spec' => 'rails_app/tests#base'
end
