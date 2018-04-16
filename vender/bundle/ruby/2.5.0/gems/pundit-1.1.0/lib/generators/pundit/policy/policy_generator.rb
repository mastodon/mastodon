module Pundit
  module Generators
    class PolicyGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def create_policy
        template 'policy.rb', File.join('app/policies', class_path, "#{file_name}_policy.rb")
      end

      hook_for :test_framework
    end
  end
end
