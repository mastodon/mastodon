module Responders
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("..", __FILE__)

      desc "Creates an initializer with default responder configuration and copy locale file"

      def create_responder_file
        create_file "lib/application_responder.rb", <<-RUBY
class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder

  # Redirects resources to the collection path (index action) instead
  # of the resource path (show action) for POST/PUT/DELETE requests.
  # include Responders::CollectionResponder
end
        RUBY
      end

      def update_application
        inject_into_class "config/application.rb", "Application", <<-RUBY
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

        RUBY
      end

      def update_application_controller
        prepend_file "app/controllers/application_controller.rb", %{require "application_responder"\n\n}
        inject_into_class "app/controllers/application_controller.rb", "ApplicationController", <<-RUBY
  self.responder = ApplicationResponder
  respond_to :html

        RUBY
      end

      def copy_locale
        copy_file "../../responders/locales/en.yml", "config/locales/responders.en.yml"
      end
    end
  end
end
