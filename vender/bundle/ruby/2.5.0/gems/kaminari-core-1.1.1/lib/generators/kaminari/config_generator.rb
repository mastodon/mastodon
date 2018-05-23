# frozen_string_literal: true
module Kaminari
  module Generators
    # rails g kaminari:config
    class ConfigGenerator < Rails::Generators::Base # :nodoc:
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc <<DESC
Description:
    Copies Kaminari configuration file to your application's initializer directory.
DESC

      def copy_config_file
        template 'kaminari_config.rb', 'config/initializers/kaminari_config.rb'
      end
    end
  end
end
