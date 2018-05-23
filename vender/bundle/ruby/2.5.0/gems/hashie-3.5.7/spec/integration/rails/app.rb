require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_view/testing/resolvers'
require 'rails/test_unit/railtie'

module RailsApp
  class Application < ::Rails::Application
    config.eager_load      = false
    config.secret_key_base = 'hashieintegrationtest'

    routes.append do
      get '/' => 'application#index'
    end
  end
end

LAYOUT = <<-HTML
<!DOCTYPE html>
<html>
<head>
  <title>TestApp</title>
  <%= csrf_meta_tags %>
</head>
<body>
<%= yield %>
</body>
</html>
HTML

INDEX = '<h1>Hello, world!</h1>'

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers

  layout 'application'

  self.view_paths = [ActionView::FixtureResolver.new(
    'layouts/application.html.erb' => LAYOUT,
    'application/index.html.erb'   => INDEX
  )]

  def index
  end
end

Bundler.require(:default, Rails.env)

RailsApp::Application.initialize!
