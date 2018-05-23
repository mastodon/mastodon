module MultiJson
  module Options
    def load_options=(options)
      OptionsCache.reset
      @load_options = options
    end

    def dump_options=(options)
      OptionsCache.reset
      @dump_options = options
    end

    def load_options(*args)
      defined?(@load_options) && get_options(@load_options, *args) || default_load_options
    end

    def dump_options(*args)
      defined?(@dump_options) && get_options(@dump_options, *args) || default_dump_options
    end

    def default_load_options
      @default_load_options ||= {}
    end

    def default_dump_options
      @default_dump_options ||= {}
    end

  private

    def get_options(options, *args)
      if options.respond_to?(:call) && options.arity
        options.arity == 0 ? options[] : options[*args]
      elsif options.respond_to?(:to_hash)
        options.to_hash
      end
    end
  end
end
