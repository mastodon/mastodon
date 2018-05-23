require "thor/command"
require "thor/core_ext/hash_with_indifferent_access"
require "thor/core_ext/ordered_hash"
require "thor/error"
require "thor/invocation"
require "thor/parser"
require "thor/shell"
require "thor/line_editor"
require "thor/util"

class Thor
  autoload :Actions,    "thor/actions"
  autoload :RakeCompat, "thor/rake_compat"
  autoload :Group,      "thor/group"

  # Shortcuts for help.
  HELP_MAPPINGS       = %w(-h -? --help -D)

  # Thor methods that should not be overwritten by the user.
  THOR_RESERVED_WORDS = %w(invoke shell options behavior root destination_root relative_root
                           action add_file create_file in_root inside run run_ruby_script)

  TEMPLATE_EXTNAME = ".tt"

  module Base
    attr_accessor :options, :parent_options, :args

    # It receives arguments in an Array and two hashes, one for options and
    # other for configuration.
    #
    # Notice that it does not check if all required arguments were supplied.
    # It should be done by the parser.
    #
    # ==== Parameters
    # args<Array[Object]>:: An array of objects. The objects are applied to their
    #                       respective accessors declared with <tt>argument</tt>.
    #
    # options<Hash>:: An options hash that will be available as self.options.
    #                 The hash given is converted to a hash with indifferent
    #                 access, magic predicates (options.skip?) and then frozen.
    #
    # config<Hash>:: Configuration for this Thor class.
    #
    def initialize(args = [], local_options = {}, config = {})
      parse_options = self.class.class_options

      # The start method splits inbound arguments at the first argument
      # that looks like an option (starts with - or --). It then calls
      # new, passing in the two halves of the arguments Array as the
      # first two parameters.

      command_options = config.delete(:command_options) # hook for start
      parse_options = parse_options.merge(command_options) if command_options
      if local_options.is_a?(Array)
        array_options = local_options
        hash_options = {}
      else
        # Handle the case where the class was explicitly instantiated
        # with pre-parsed options.
        array_options = []
        hash_options = local_options
      end

      # Let Thor::Options parse the options first, so it can remove
      # declared options from the array. This will leave us with
      # a list of arguments that weren't declared.
      stop_on_unknown = self.class.stop_on_unknown_option? config[:current_command]
      disable_required_check = self.class.disable_required_check? config[:current_command]
      opts = Thor::Options.new(parse_options, hash_options, stop_on_unknown, disable_required_check)
      self.options = opts.parse(array_options)
      self.options = config[:class_options].merge(options) if config[:class_options]

      # If unknown options are disallowed, make sure that none of the
      # remaining arguments looks like an option.
      opts.check_unknown! if self.class.check_unknown_options?(config)

      # Add the remaining arguments from the options parser to the
      # arguments passed in to initialize. Then remove any positional
      # arguments declared using #argument (this is primarily used
      # by Thor::Group). Tis will leave us with the remaining
      # positional arguments.
      to_parse  = args
      to_parse += opts.remaining unless self.class.strict_args_position?(config)

      thor_args = Thor::Arguments.new(self.class.arguments)
      thor_args.parse(to_parse).each { |k, v| __send__("#{k}=", v) }
      @args = thor_args.remaining
    end

    class << self
      def included(base) #:nodoc:
        base.extend ClassMethods
        base.send :include, Invocation
        base.send :include, Shell
      end

      # Returns the classes that inherits from Thor or Thor::Group.
      #
      # ==== Returns
      # Array[Class]
      #
      def subclasses
        @subclasses ||= []
      end

      # Returns the files where the subclasses are kept.
      #
      # ==== Returns
      # Hash[path<String> => Class]
      #
      def subclass_files
        @subclass_files ||= Hash.new { |h, k| h[k] = [] }
      end

      # Whenever a class inherits from Thor or Thor::Group, we should track the
      # class and the file on Thor::Base. This is the method responsable for it.
      #
      def register_klass_file(klass) #:nodoc:
        file = caller[1].match(/(.*):\d+/)[1]
        Thor::Base.subclasses << klass unless Thor::Base.subclasses.include?(klass)

        file_subclasses = Thor::Base.subclass_files[File.expand_path(file)]
        file_subclasses << klass unless file_subclasses.include?(klass)
      end
    end

    module ClassMethods
      def attr_reader(*) #:nodoc:
        no_commands { super }
      end

      def attr_writer(*) #:nodoc:
        no_commands { super }
      end

      def attr_accessor(*) #:nodoc:
        no_commands { super }
      end

      # If you want to raise an error for unknown options, call check_unknown_options!
      # This is disabled by default to allow dynamic invocations.
      def check_unknown_options!
        @check_unknown_options = true
      end

      def check_unknown_options #:nodoc:
        @check_unknown_options ||= from_superclass(:check_unknown_options, false)
      end

      def check_unknown_options?(config) #:nodoc:
        !!check_unknown_options
      end

      # If you want to raise an error when the default value of an option does not match
      # the type call check_default_type!
      # This is disabled by default for compatibility.
      def check_default_type!
        @check_default_type = true
      end

      def check_default_type #:nodoc:
        @check_default_type ||= from_superclass(:check_default_type, false)
      end

      def check_default_type? #:nodoc:
        !!check_default_type
      end

      # If true, option parsing is suspended as soon as an unknown option or a
      # regular argument is encountered.  All remaining arguments are passed to
      # the command as regular arguments.
      def stop_on_unknown_option?(command_name) #:nodoc:
        false
      end

      # If true, option set will not suspend the execution of the command when
      # a required option is not provided.
      def disable_required_check?(command_name) #:nodoc:
        false
      end

      # If you want only strict string args (useful when cascading thor classes),
      # call strict_args_position! This is disabled by default to allow dynamic
      # invocations.
      def strict_args_position!
        @strict_args_position = true
      end

      def strict_args_position #:nodoc:
        @strict_args_position ||= from_superclass(:strict_args_position, false)
      end

      def strict_args_position?(config) #:nodoc:
        !!strict_args_position
      end

      # Adds an argument to the class and creates an attr_accessor for it.
      #
      # Arguments are different from options in several aspects. The first one
      # is how they are parsed from the command line, arguments are retrieved
      # from position:
      #
      #   thor command NAME
      #
      # Instead of:
      #
      #   thor command --name=NAME
      #
      # Besides, arguments are used inside your code as an accessor (self.argument),
      # while options are all kept in a hash (self.options).
      #
      # Finally, arguments cannot have type :default or :boolean but can be
      # optional (supplying :optional => :true or :required => false), although
      # you cannot have a required argument after a non-required argument. If you
      # try it, an error is raised.
      #
      # ==== Parameters
      # name<Symbol>:: The name of the argument.
      # options<Hash>:: Described below.
      #
      # ==== Options
      # :desc     - Description for the argument.
      # :required - If the argument is required or not.
      # :optional - If the argument is optional or not.
      # :type     - The type of the argument, can be :string, :hash, :array, :numeric.
      # :default  - Default value for this argument. It cannot be required and have default values.
      # :banner   - String to show on usage notes.
      #
      # ==== Errors
      # ArgumentError:: Raised if you supply a required argument after a non required one.
      #
      def argument(name, options = {})
        is_thor_reserved_word?(name, :argument)
        no_commands { attr_accessor name }

        required = if options.key?(:optional)
          !options[:optional]
        elsif options.key?(:required)
          options[:required]
        else
          options[:default].nil?
        end

        remove_argument name

        if required
          arguments.each do |argument|
            next if argument.required?
            raise ArgumentError, "You cannot have #{name.to_s.inspect} as required argument after " \
                                "the non-required argument #{argument.human_name.inspect}."
          end
        end

        options[:required] = required

        arguments << Thor::Argument.new(name, options)
      end

      # Returns this class arguments, looking up in the ancestors chain.
      #
      # ==== Returns
      # Array[Thor::Argument]
      #
      def arguments
        @arguments ||= from_superclass(:arguments, [])
      end

      # Adds a bunch of options to the set of class options.
      #
      #   class_options :foo => false, :bar => :required, :baz => :string
      #
      # If you prefer more detailed declaration, check class_option.
      #
      # ==== Parameters
      # Hash[Symbol => Object]
      #
      def class_options(options = nil)
        @class_options ||= from_superclass(:class_options, {})
        build_options(options, @class_options) if options
        @class_options
      end

      # Adds an option to the set of class options
      #
      # ==== Parameters
      # name<Symbol>:: The name of the argument.
      # options<Hash>:: Described below.
      #
      # ==== Options
      # :desc::     -- Description for the argument.
      # :required:: -- If the argument is required or not.
      # :default::  -- Default value for this argument.
      # :group::    -- The group for this options. Use by class options to output options in different levels.
      # :aliases::  -- Aliases for this option. <b>Note:</b> Thor follows a convention of one-dash-one-letter options. Thus aliases like "-something" wouldn't be parsed; use either "\--something" or "-s" instead.
      # :type::     -- The type of the argument, can be :string, :hash, :array, :numeric or :boolean.
      # :banner::   -- String to show on usage notes.
      # :hide::     -- If you want to hide this option from the help.
      #
      def class_option(name, options = {})
        build_option(name, options, class_options)
      end

      # Removes a previous defined argument. If :undefine is given, undefine
      # accessors as well.
      #
      # ==== Parameters
      # names<Array>:: Arguments to be removed
      #
      # ==== Examples
      #
      #   remove_argument :foo
      #   remove_argument :foo, :bar, :baz, :undefine => true
      #
      def remove_argument(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}

        names.each do |name|
          arguments.delete_if { |a| a.name == name.to_s }
          undef_method name, "#{name}=" if options[:undefine]
        end
      end

      # Removes a previous defined class option.
      #
      # ==== Parameters
      # names<Array>:: Class options to be removed
      #
      # ==== Examples
      #
      #   remove_class_option :foo
      #   remove_class_option :foo, :bar, :baz
      #
      def remove_class_option(*names)
        names.each do |name|
          class_options.delete(name)
        end
      end

      # Defines the group. This is used when thor list is invoked so you can specify
      # that only commands from a pre-defined group will be shown. Defaults to standard.
      #
      # ==== Parameters
      # name<String|Symbol>
      #
      def group(name = nil)
        if name
          @group = name.to_s
        else
          @group ||= from_superclass(:group, "standard")
        end
      end

      # Returns the commands for this Thor class.
      #
      # ==== Returns
      # OrderedHash:: An ordered hash with commands names as keys and Thor::Command
      #               objects as values.
      #
      def commands
        @commands ||= Thor::CoreExt::OrderedHash.new
      end
      alias_method :tasks, :commands

      # Returns the commands for this Thor class and all subclasses.
      #
      # ==== Returns
      # OrderedHash:: An ordered hash with commands names as keys and Thor::Command
      #               objects as values.
      #
      def all_commands
        @all_commands ||= from_superclass(:all_commands, Thor::CoreExt::OrderedHash.new)
        @all_commands.merge!(commands)
      end
      alias_method :all_tasks, :all_commands

      # Removes a given command from this Thor class. This is usually done if you
      # are inheriting from another class and don't want it to be available
      # anymore.
      #
      # By default it only remove the mapping to the command. But you can supply
      # :undefine => true to undefine the method from the class as well.
      #
      # ==== Parameters
      # name<Symbol|String>:: The name of the command to be removed
      # options<Hash>:: You can give :undefine => true if you want commands the method
      #                 to be undefined from the class as well.
      #
      def remove_command(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}

        names.each do |name|
          commands.delete(name.to_s)
          all_commands.delete(name.to_s)
          undef_method name if options[:undefine]
        end
      end
      alias_method :remove_task, :remove_command

      # All methods defined inside the given block are not added as commands.
      #
      # So you can do:
      #
      #   class MyScript < Thor
      #     no_commands do
      #       def this_is_not_a_command
      #       end
      #     end
      #   end
      #
      # You can also add the method and remove it from the command list:
      #
      #   class MyScript < Thor
      #     def this_is_not_a_command
      #     end
      #     remove_command :this_is_not_a_command
      #   end
      #
      def no_commands
        @no_commands = true
        yield
      ensure
        @no_commands = false
      end
      alias_method :no_tasks, :no_commands

      # Sets the namespace for the Thor or Thor::Group class. By default the
      # namespace is retrieved from the class name. If your Thor class is named
      # Scripts::MyScript, the help method, for example, will be called as:
      #
      #   thor scripts:my_script -h
      #
      # If you change the namespace:
      #
      #   namespace :my_scripts
      #
      # You change how your commands are invoked:
      #
      #   thor my_scripts -h
      #
      # Finally, if you change your namespace to default:
      #
      #   namespace :default
      #
      # Your commands can be invoked with a shortcut. Instead of:
      #
      #   thor :my_command
      #
      def namespace(name = nil)
        if name
          @namespace = name.to_s
        else
          @namespace ||= Thor::Util.namespace_from_thor_class(self)
        end
      end

      # Parses the command and options from the given args, instantiate the class
      # and invoke the command. This method is used when the arguments must be parsed
      # from an array. If you are inside Ruby and want to use a Thor class, you
      # can simply initialize it:
      #
      #   script = MyScript.new(args, options, config)
      #   script.invoke(:command, first_arg, second_arg, third_arg)
      #
      def start(given_args = ARGV, config = {})
        config[:shell] ||= Thor::Base.shell.new
        dispatch(nil, given_args.dup, nil, config)
      rescue Thor::Error => e
        config[:debug] || ENV["THOR_DEBUG"] == "1" ? (raise e) : config[:shell].error(e.message)
        exit(1) if exit_on_failure?
      rescue Errno::EPIPE
        # This happens if a thor command is piped to something like `head`,
        # which closes the pipe when it's done reading. This will also
        # mean that if the pipe is closed, further unnecessary
        # computation will not occur.
        exit(0)
      end

      # Allows to use private methods from parent in child classes as commands.
      #
      # ==== Parameters
      #   names<Array>:: Method names to be used as commands
      #
      # ==== Examples
      #
      #   public_command :foo
      #   public_command :foo, :bar, :baz
      #
      def public_command(*names)
        names.each do |name|
          class_eval "def #{name}(*); super end"
        end
      end
      alias_method :public_task, :public_command

      def handle_no_command_error(command, has_namespace = $thor_runner) #:nodoc:
        raise UndefinedCommandError, "Could not find command #{command.inspect} in #{namespace.inspect} namespace." if has_namespace
        raise UndefinedCommandError, "Could not find command #{command.inspect}."
      end
      alias_method :handle_no_task_error, :handle_no_command_error

      def handle_argument_error(command, error, args, arity) #:nodoc:
        name = [command.ancestor_name, command.name].compact.join(" ")
        msg = "ERROR: \"#{basename} #{name}\" was called with ".dup
        msg << "no arguments"               if     args.empty?
        msg << "arguments " << args.inspect unless args.empty?
        msg << "\nUsage: #{banner(command).inspect}"
        raise InvocationError, msg
      end

    protected

      # Prints the class options per group. If an option does not belong to
      # any group, it's printed as Class option.
      #
      def class_options_help(shell, groups = {}) #:nodoc:
        # Group options by group
        class_options.each do |_, value|
          groups[value.group] ||= []
          groups[value.group] << value
        end

        # Deal with default group
        global_options = groups.delete(nil) || []
        print_options(shell, global_options)

        # Print all others
        groups.each do |group_name, options|
          print_options(shell, options, group_name)
        end
      end

      # Receives a set of options and print them.
      def print_options(shell, options, group_name = nil)
        return if options.empty?

        list = []
        padding = options.map { |o| o.aliases.size }.max.to_i * 4

        options.each do |option|
          next if option.hide
          item = [option.usage(padding)]
          item.push(option.description ? "# #{option.description}" : "")

          list << item
          list << ["", "# Default: #{option.default}"] if option.show_default?
          list << ["", "# Possible values: #{option.enum.join(', ')}"] if option.enum
        end

        shell.say(group_name ? "#{group_name} options:" : "Options:")
        shell.print_table(list, :indent => 2)
        shell.say ""
      end

      # Raises an error if the word given is a Thor reserved word.
      def is_thor_reserved_word?(word, type) #:nodoc:
        return false unless THOR_RESERVED_WORDS.include?(word.to_s)
        raise "#{word.inspect} is a Thor reserved word and cannot be defined as #{type}"
      end

      # Build an option and adds it to the given scope.
      #
      # ==== Parameters
      # name<Symbol>:: The name of the argument.
      # options<Hash>:: Described in both class_option and method_option.
      # scope<Hash>:: Options hash that is being built up
      def build_option(name, options, scope) #:nodoc:
        scope[name] = Thor::Option.new(name, options.merge(:check_default_type => check_default_type?))
      end

      # Receives a hash of options, parse them and add to the scope. This is a
      # fast way to set a bunch of options:
      #
      #   build_options :foo => true, :bar => :required, :baz => :string
      #
      # ==== Parameters
      # Hash[Symbol => Object]
      def build_options(options, scope) #:nodoc:
        options.each do |key, value|
          scope[key] = Thor::Option.parse(key, value)
        end
      end

      # Finds a command with the given name. If the command belongs to the current
      # class, just return it, otherwise dup it and add the fresh copy to the
      # current command hash.
      def find_and_refresh_command(name) #:nodoc:
        if commands[name.to_s]
          commands[name.to_s]
        elsif command = all_commands[name.to_s] # rubocop:disable AssignmentInCondition
          commands[name.to_s] = command.clone
        else
          raise ArgumentError, "You supplied :for => #{name.inspect}, but the command #{name.inspect} could not be found."
        end
      end
      alias_method :find_and_refresh_task, :find_and_refresh_command

      # Everytime someone inherits from a Thor class, register the klass
      # and file into baseclass.
      def inherited(klass)
        Thor::Base.register_klass_file(klass)
        klass.instance_variable_set(:@no_commands, false)
      end

      # Fire this callback whenever a method is added. Added methods are
      # tracked as commands by invoking the create_command method.
      def method_added(meth)
        meth = meth.to_s

        if meth == "initialize"
          initialize_added
          return
        end

        # Return if it's not a public instance method
        return unless public_method_defined?(meth.to_sym)

        @no_commands ||= false
        return if @no_commands || !create_command(meth)

        is_thor_reserved_word?(meth, :command)
        Thor::Base.register_klass_file(self)
      end

      # Retrieves a value from superclass. If it reaches the baseclass,
      # returns default.
      def from_superclass(method, default = nil)
        if self == baseclass || !superclass.respond_to?(method, true)
          default
        else
          value = superclass.send(method)

          # Ruby implements `dup` on Object, but raises a `TypeError`
          # if the method is called on immediates. As a result, we
          # don't have a good way to check whether dup will succeed
          # without calling it and rescuing the TypeError.
          begin
            value.dup
          rescue TypeError
            value
          end

        end
      end

      # A flag that makes the process exit with status 1 if any error happens.
      def exit_on_failure?
        false
      end

      #
      # The basename of the program invoking the thor class.
      #
      def basename
        File.basename($PROGRAM_NAME).split(" ").first
      end

      # SIGNATURE: Sets the baseclass. This is where the superclass lookup
      # finishes.
      def baseclass #:nodoc:
      end

      # SIGNATURE: Creates a new command if valid_command? is true. This method is
      # called when a new method is added to the class.
      def create_command(meth) #:nodoc:
      end
      alias_method :create_task, :create_command

      # SIGNATURE: Defines behavior when the initialize method is added to the
      # class.
      def initialize_added #:nodoc:
      end

      # SIGNATURE: The hook invoked by start.
      def dispatch(command, given_args, given_opts, config) #:nodoc:
        raise NotImplementedError
      end
    end
  end
end
