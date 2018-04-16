# frozen_string_literal: true

require "rails"
require "browser"

class PagesController < ActionController::Base
  def home
    render html: "#{browser.name}:#{browser.accept_language.first.full}"
  end
end

class SampleApp < Rails::Application
  config.secret_token = "99f19f08db7a37bdcb9d6701f54dca"
  config.secret_key_base = "99f19f08db7a37bdcb9d6701f54dca"
  config.eager_load = true
  config.active_support.deprecation = :log

  routes.append do
    default_headers = {"Content-Type" => "text/html"}

    root to: ->(_env) { [200, default_headers, ["ROOT"]] }
    get "upgrade", to: lambda {|env|
      browser = Rack::Request.new(env).params["browser"]
      [200, default_headers, ["UPGRADE: #{browser}"]]
    }, as: "upgrade"

    get "/asset", to: proc {
      [200, {"Content-Type" => "image/png"}, []]
    }

    get "/home", to: "pages#home"
  end

  config.middleware.use Browser::Middleware do
    redirect_to upgrade_path(browser: "ie6") if browser.ie?(6)
    redirect_to upgrade_path(browser: "ie7") if browser.ie?(7)
    redirect_to "/invalid" if browser.ie?(8)
  end
end

SampleApp.initialize!
