require 'rails/generators/named_base'

module Sidekiq
  module Generators # :nodoc:
    class WorkerGenerator < ::Rails::Generators::NamedBase # :nodoc:
      desc 'This generator creates a Sidekiq Worker in app/workers and a corresponding test'

      check_class_collision suffix: 'Worker'

      def self.default_generator_root
        File.dirname(__FILE__)
      end

      def create_worker_file
        template 'worker.rb.erb', File.join('app/workers', class_path, "#{file_name}_worker.rb")
      end

      def create_test_file
        if defined?(RSpec)
          create_worker_spec
        else
          create_worker_test
        end
      end

      private

      def create_worker_spec
        template_file = File.join(
            'spec/workers',
            class_path,
            "#{file_name}_worker_spec.rb"
        )
        template 'worker_spec.rb.erb', template_file
      end

      def create_worker_test
        template_file = File.join(
            'test/workers',
            class_path,
            "#{file_name}_worker_test.rb"
        )
        template 'worker_test.rb.erb', template_file
      end


    end
  end
end
