module TestUnit
  module Generators
    class PolicyGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def create_policy_test
        template 'policy_test.rb', File.join('test/policies', class_path, "#{file_name}_policy_test.rb")
      end
    end
  end
end
