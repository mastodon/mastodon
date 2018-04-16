class Thor
  module Invocation
    def self.included(base) #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      # This method is responsible for receiving a name and find the proper
      # class and command for it. The key is an optional parameter which is
      # available only in class methods invocations (i.e. in Thor::Group).
      def prepare_for_invocation(key, name) #:nodoc:
        case name
        when Symbol, String
          Thor::Util.find_class_and_command_by_namespace(name.to_s, !key)
        else
          name
        end
      end
    end

    # Make initializer aware of invocations and the initialization args.
    def initialize(args = [], options = {}, config = {}, &block) #:nodoc:
      @_invocations = config[:invocations] || Hash.new { |h, k| h[k] = [] }
      @_initializer = [args, options, config]
      super
    end

    # Make the current command chain accessible with in a Thor-(sub)command
    def current_command_chain
      @_invocations.values.flatten.map(&:to_sym)
    end

    # Receives a name and invokes it. The name can be a string (either "command" or
    # "namespace:command"), a Thor::Command, a Class or a Thor instance. If the
    # command cannot be guessed by name, it can also be supplied as second argument.
    #
    # You can also supply the arguments, options and configuration values for
    # the command to be invoked, if none is given, the same values used to
    # initialize the invoker are used to initialize the invoked.
    #
    # When no name is given, it will invoke the default command of the current class.
    #
    # ==== Examples
    #
    #   class A < Thor
    #     def foo
    #       invoke :bar
    #       invoke "b:hello", ["Erik"]
    #     end
    #
    #     def bar
    #       invoke "b:hello", ["Erik"]
    #     end
    #   end
    #
    #   class B < Thor
    #     def hello(name)
    #       puts "hello #{name}"
    #     end
    #   end
    #
    # You can notice that the method "foo" above invokes two commands: "bar",
    # which belongs to the same class and "hello" which belongs to the class B.
    #
    # By using an invocation system you ensure that a command is invoked only once.
    # In the example above, invoking "foo" will invoke "b:hello" just once, even
    # if it's invoked later by "bar" method.
    #
    # When class A invokes class B, all arguments used on A initialization are
    # supplied to B. This allows lazy parse of options. Let's suppose you have
    # some rspec commands:
    #
    #   class Rspec < Thor::Group
    #     class_option :mock_framework, :type => :string, :default => :rr
    #
    #     def invoke_mock_framework
    #       invoke "rspec:#{options[:mock_framework]}"
    #     end
    #   end
    #
    # As you noticed, it invokes the given mock framework, which might have its
    # own options:
    #
    #   class Rspec::RR < Thor::Group
    #     class_option :style, :type => :string, :default => :mock
    #   end
    #
    # Since it's not rspec concern to parse mock framework options, when RR
    # is invoked all options are parsed again, so RR can extract only the options
    # that it's going to use.
    #
    # If you want Rspec::RR to be initialized with its own set of options, you
    # have to do that explicitly:
    #
    #   invoke "rspec:rr", [], :style => :foo
    #
    # Besides giving an instance, you can also give a class to invoke:
    #
    #   invoke Rspec::RR, [], :style => :foo
    #
    def invoke(name = nil, *args)
      if name.nil?
        warn "[Thor] Calling invoke() without argument is deprecated. Please use invoke_all instead.\n#{caller.join("\n")}"
        return invoke_all
      end

      args.unshift(nil) if args.first.is_a?(Array) || args.first.nil?
      command, args, opts, config = args

      klass, command = _retrieve_class_and_command(name, command)
      raise "Missing Thor class for invoke #{name}" unless klass
      raise "Expected Thor class, got #{klass}" unless klass <= Thor::Base

      args, opts, config = _parse_initialization_options(args, opts, config)
      klass.send(:dispatch, command, args, opts, config) do |instance|
        instance.parent_options = options
      end
    end

    # Invoke the given command if the given args.
    def invoke_command(command, *args) #:nodoc:
      current = @_invocations[self.class]

      unless current.include?(command.name)
        current << command.name
        command.run(self, *args)
      end
    end
    alias_method :invoke_task, :invoke_command

    # Invoke all commands for the current instance.
    def invoke_all #:nodoc:
      self.class.all_commands.map { |_, command| invoke_command(command) }
    end

    # Invokes using shell padding.
    def invoke_with_padding(*args)
      with_padding { invoke(*args) }
    end

  protected

    # Configuration values that are shared between invocations.
    def _shared_configuration #:nodoc:
      {:invocations => @_invocations}
    end

    # This method simply retrieves the class and command to be invoked.
    # If the name is nil or the given name is a command in the current class,
    # use the given name and return self as class. Otherwise, call
    # prepare_for_invocation in the current class.
    def _retrieve_class_and_command(name, sent_command = nil) #:nodoc:
      if name.nil?
        [self.class, nil]
      elsif self.class.all_commands[name.to_s]
        [self.class, name.to_s]
      else
        klass, command = self.class.prepare_for_invocation(nil, name)
        [klass, command || sent_command]
      end
    end
    alias_method :_retrieve_class_and_task, :_retrieve_class_and_command

    # Initialize klass using values stored in the @_initializer.
    def _parse_initialization_options(args, opts, config) #:nodoc:
      stored_args, stored_opts, stored_config = @_initializer

      args ||= stored_args.dup
      opts ||= stored_opts.dup

      config ||= {}
      config = stored_config.merge(_shared_configuration).merge!(config)

      [args, opts, config]
    end
  end
end
