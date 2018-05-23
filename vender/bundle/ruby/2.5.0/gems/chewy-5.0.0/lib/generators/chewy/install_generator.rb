module Chewy
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      def copy_configuration
        template 'chewy.yml', 'config/chewy.yml'
      end
    end
  end
end
