module Pundit
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def copy_application_policy
        template 'application_policy.rb', 'app/policies/application_policy.rb'
      end
    end
  end
end
