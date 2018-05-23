module Paperclip
  module ProcessorHelpers
    class NoSuchProcessor < StandardError; end

    def processor(name) #:nodoc:
      @known_processors ||= {}
      if @known_processors[name.to_s]
        @known_processors[name.to_s]
      else
        name = name.to_s.camelize
        load_processor(name) unless Paperclip.const_defined?(name)
        processor = Paperclip.const_get(name)
        @known_processors[name.to_s] = processor
      end
    end

    def load_processor(name)
      if defined?(Rails.root) && Rails.root
        filename = "#{name.to_s.underscore}.rb"
        directories = %w(lib/paperclip lib/paperclip_processors)

        required = directories.map do |directory|
          pathname = File.expand_path(Rails.root.join(directory, filename))
          file_exists = File.exist?(pathname)
          require pathname if file_exists
          file_exists
        end

        raise LoadError, "Could not find the '#{name}' processor in any of these paths: #{directories.join(', ')}" unless required.any?
      end
    end

    def clear_processors!
      @known_processors.try(:clear)
    end

    # You can add your own processor via the Paperclip configuration. Normally
    # Paperclip will load all processors from the
    # Rails.root/lib/paperclip_processors directory, but here you can add any
    # existing class using this mechanism.
    #
    #   Paperclip.configure do |c|
    #     c.register_processor :watermarker, WatermarkingProcessor.new
    #   end
    def register_processor(name, processor)
      @known_processors ||= {}
      @known_processors[name.to_s] = processor
    end
  end
end
