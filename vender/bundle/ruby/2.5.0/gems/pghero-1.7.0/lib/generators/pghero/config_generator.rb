require "rails/generators"

module Pghero
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def create_initializer
        template "config.yml", "config/pghero.yml"
      end
    end
  end
end
