module Rspec
  module Generators
    class PolicyGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def create_policy_spec
        template 'policy_spec.rb', File.join('spec/policies', class_path, "#{file_name}_policy_spec.rb")
      end
    end
  end
end
