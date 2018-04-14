module Temple
  module Mixins
    # @api private
    module EngineDSL
      def chain_modified!
      end

      def append(*args, &block)
        chain << chain_element(args, block)
        chain_modified!
      end

      def prepend(*args, &block)
        chain.unshift(chain_element(args, block))
        chain_modified!
      end

      def remove(name)
        name = chain_name(name)
        raise "#{name} not found" unless chain.reject! {|i| name === i.first }
        chain_modified!
      end

      alias use append

      def before(name, *args, &block)
        name = chain_name(name)
        e = chain_element(args, block)
        chain.map! {|f| name === f.first ? [e, f] : [f] }.flatten!(1)
        raise "#{name} not found" unless chain.include?(e)
        chain_modified!
      end

      def after(name, *args, &block)
        name = chain_name(name)
        e = chain_element(args, block)
        chain.map! {|f| name === f.first ? [f, e] : [f] }.flatten!(1)
        raise "#{name} not found" unless chain.include?(e)
        chain_modified!
      end

      def replace(name, *args, &block)
        name = chain_name(name)
        e = chain_element(args, block)
        chain.map! {|f| name === f.first ? e : f }
        raise "#{name} not found" unless chain.include?(e)
        chain_modified!
      end

      # Shortcuts to access namespaces
      { filter: Temple::Filters,
        generator: Temple::Generators,
        html: Temple::HTML }.each do |method, mod|
        define_method(method) do |name, *options|
          use(name, mod.const_get(name), *options)
        end
      end

      private

      def chain_name(name)
        case name
        when Class
          name.name.to_sym
        when Symbol, String
          name.to_sym
        when Regexp
          name
        else
          raise(ArgumentError, 'Name argument must be Class, Symbol, String or Regexp')
        end
      end

      def chain_class_constructor(filter, local_options)
        define_options(filter.options.valid_keys) if respond_to?(:define_options) && filter.respond_to?(:options)
        proc do |engine|
          opts = {}.update(engine.options)
          opts.delete_if {|k,v| !filter.options.valid_key?(k) } if filter.respond_to?(:options)
          opts.update(local_options) if local_options
          filter.new(opts)
        end
      end

      def chain_proc_constructor(name, filter)
        raise(ArgumentError, 'Proc or blocks must have arity 0 or 1') if filter.arity > 1
        method_name = "FILTER #{name}"
        c = Class === self ? self : singleton_class
        filter = c.class_eval { define_method(method_name, &filter); instance_method(method_name) }
        proc do |engine|
          if filter.arity == 1
            # the proc takes one argument, e.g. use(:Filter) {|exp| exp }
            filter.bind(engine)
          else
            f = filter.bind(engine).call
            if f.respond_to? :call
              # the proc returns a callable object, e.g. use(:Filter) { Filter.new }
              f
            else
              raise(ArgumentError, 'Proc or blocks must return a Callable or a Class') unless f.respond_to? :new
              # the proc returns a class, e.g. use(:Filter) { Filter }
              f.new(f.respond_to?(:options) ? engine.options.to_hash.select {|k,v| f.options.valid_key?(k) } : engine.options)
            end
          end
        end
      end

      def chain_element(args, block)
        name = args.shift
        if Class === name
          filter = name
          name = filter.name.to_sym
        else
          raise(ArgumentError, 'Name argument must be Class or Symbol') unless Symbol === name
        end

        if block
          raise(ArgumentError, 'Class and block argument are not allowed at the same time') if filter
          filter = block
        end

        filter ||= args.shift

        case filter
        when Proc
          # Proc or block argument
          # The proc is converted to a method of the engine class.
          # The proc can then access the option hash of the engine.
          raise(ArgumentError, 'Too many arguments') unless args.empty?
          [name, chain_proc_constructor(name, filter)]
        when Class
          # Class argument (e.g Filter class)
          # The options are passed to the classes constructor.
          raise(ArgumentError, 'Too many arguments') if args.size > 1
          [name, chain_class_constructor(filter, args.first)]
        else
          # Other callable argument (e.g. Object of class which implements #call or Method)
          # The callable has no access to the option hash of the engine.
          raise(ArgumentError, 'Too many arguments') unless args.empty?
          raise(ArgumentError, 'Class or callable argument is required') unless filter.respond_to?(:call)
          [name, proc { filter }]
        end
      end
    end
  end
end
