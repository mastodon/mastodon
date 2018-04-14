module Temple
  module Templates
    class Rails
      extend Mixins::Template

      def call(template)
        opts = {}.update(self.class.options).update(file: template.identifier)
        self.class.compile(template.source, opts)
      end

      def supports_streaming?
        self.class.options[:streaming]
      end

      def self.register_as(*names)
        raise 'Rails is not loaded - Temple::Templates::Rails cannot be used' unless defined?(::ActionView)
        if ::ActiveSupport::VERSION::MAJOR < 3 || ::ActiveSupport::VERSION::MAJOR == 3 && ::ActiveSupport::VERSION::MINOR < 1
          raise "Temple supports only Rails 3.1 and greater, your Rails version is #{::ActiveSupport::VERSION::STRING}"
        end
        names.each do |name|
          ::ActionView::Template.register_template_handler name.to_sym, new
        end
      end
    end
  end
end
