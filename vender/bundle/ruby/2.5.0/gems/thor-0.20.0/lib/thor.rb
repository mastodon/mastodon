require "set"
require "thor/base"

class Thor
  class << self
    # Allows for custom "Command" package naming.
    #
    # === Parameters
    # name<String>
    # options<Hash>
    #
    def package_name(name, _ = {})
      @package_name = name.nil? || name == "" ? nil : name
    end

    # Sets the default command when thor is executed without an explicit command to be called.
    #
    # ==== Parameters
    # meth<Symbol>:: name of the default command
    #
    def default_command(meth = nil)
      if meth
        @default_command = meth == :none ? "help" : meth.to_s
      else
        @default_command ||= from_superclass(:default_command, "help")
      end
    end
    alias_method :default_task, :default_command

    # Registers another Thor subclass as a command.
    #
    # ==== Parameters
    # klass<Class>:: Thor subclass to register
    # command<String>:: Subcommand name to use
    # usage<String>:: Short usage for the subcommand
    # description<String>:: Description for the subcommand
    def register(klass, subcommand_name, usage, description, options = {})
      if klass <= Thor::Group
        desc usage, description, options
        define_method(subcommand_name) { |*args| invoke(klass, args) }
      else
        desc usage, description, options
        subcommand subcommand_name, klass
      end
    end

    # Defines the usage and the description of the next command.
    #
    # ==== Parameters
    # usage<String>
    # description<String>
    # options<String>
    #
    def desc(usage, description, options = {})
      if options[:for]
        command = find_and_refresh_command(options[:for])
        command.usage = usage             if usage
        command.description = description if description
      else
        @usage = usage
        @desc = description
        @hide = options[:hide] || false
      end
    end

    # Defines the long description of the next command.
    #
    # ==== Parameters
    # long description<String>
    #
    def long_desc(long_description, options = {})
      if options[:for]
        command = find_and_refresh_command(options[:for])
        command.long_description = long_description if long_description
      else
        @long_desc = long_description
      end
    end

    # Maps an input to a command. If you define:
    #
    #   map "-T" => "list"
    #
    # Running:
    #
    #   thor -T
    #
    # Will invoke the list command.
    #
    # ==== Parameters
    # Hash[String|Array => Symbol]:: Maps the string or the strings in the array to the given command.
    #
    def map(mappings = nil)
      @map ||= from_superclass(:map, {})

      if mappings
        mappings.each do |key, value|
          if key.respond_to?(:each)
            key.each { |subkey| @map[subkey] = value }
          else
            @map[key] = value
          end
        end
      end

      @map
    end

    # Declares the options for the next command to be declared.
    #
    # ==== Parameters
    # Hash[Symbol => Object]:: The hash key is the name of the option and the value
    # is the type of the option. Can be :string, :array, :hash, :boolean, :numeric
    # or :required (string). If you give a value, the type of the value is used.
    #
    def method_options(options = nil)
      @method_options ||= {}
      build_options(options, @method_options) if options
      @method_options
    end

    alias_method :options, :method_options

    # Adds an option to the set of method options. If :for is given as option,
    # it allows you to change the options from a previous defined command.
    #
    #   def previous_command
    #     # magic
    #   end
    #
    #   method_option :foo => :bar, :for => :previous_command
    #
    #   def next_command
    #     # magic
    #   end
    #
    # ==== Parameters
    # name<Symbol>:: The name of the argument.
    # options<Hash>:: Described below.
    #
    # ==== Options
    # :desc     - Description for the argument.
    # :required - If the argument is required or not.
    # :default  - Default value for this argument. It cannot be required and have default values.
    # :aliases  - Aliases for this option.
    # :type     - The type of the argument, can be :string, :hash, :array, :numeric or :boolean.
    # :banner   - String to show on usage notes.
    # :hide     - If you want to hide this option from the help.
    #
    def method_option(name, options = {})
      scope = if options[:for]
        find_and_refresh_command(options[:for]).options
      else
        method_options
      end

      build_option(name, options, scope)
    end
    alias_method :option, :method_option

    # Prints help information for the given command.
    #
    # ==== Parameters
    # shell<Thor::Shell>
    # command_name<String>
    #
    def command_help(shell, command_name)
      meth = normalize_command_name(command_name)
      command = all_commands[meth]
      handle_no_command_error(meth) unless command

      shell.say "Usage:"
      shell.say "  #{banner(command)}"
      shell.say
      class_options_help(shell, nil => command.options.values)
      if command.long_description
        shell.say "Description:"
        shell.print_wrapped(command.long_description, :indent => 2)
      else
        shell.say command.description
      end
    end
    alias_method :task_help, :command_help

    # Prints help information for this class.
    #
    # ==== Parameters
    # shell<Thor::Shell>
    #
    def help(shell, subcommand = false)
      list = printable_commands(true, subcommand)
      Thor::Util.thor_classes_in(self).each do |klass|
        list += klass.printable_commands(false)
      end
      list.sort! { |a, b| a[0] <=> b[0] }

      if defined?(@package_name) && @package_name
        shell.say "#{@package_name} commands:"
      else
        shell.say "Commands:"
      end

      shell.print_table(list, :indent => 2, :truncate => true)
      shell.say
      class_options_help(shell)
    end

    # Returns commands ready to be printed.
    def printable_commands(all = true, subcommand = false)
      (all ? all_commands : commands).map do |_, command|
        next if command.hidden?
        item = []
        item << banner(command, false, subcommand)
        item << (command.description ? "# #{command.description.gsub(/\s+/m, ' ')}" : "")
        item
      end.compact
    end
    alias_method :printable_tasks, :printable_commands

    def subcommands
      @subcommands ||= from_superclass(:subcommands, [])
    end
    alias_method :subtasks, :subcommands

    def subcommand_classes
      @subcommand_classes ||= {}
    end

    def subcommand(subcommand, subcommand_class)
      subcommands << subcommand.to_s
      subcommand_class.subcommand_help subcommand
      subcommand_classes[subcommand.to_s] = subcommand_class

      define_method(subcommand) do |*args|
        args, opts = Thor::Arguments.split(args)
        invoke_args = [args, opts, {:invoked_via_subcommand => true, :class_options => options}]
        invoke_args.unshift "help" if opts.delete("--help") || opts.delete("-h")
        invoke subcommand_class, *invoke_args
      end
      subcommand_class.commands.each do |_meth, command|
        command.ancestor_name = subcommand
      end
    end
    alias_method :subtask, :subcommand

    # Extend check unknown options to accept a hash of conditions.
    #
    # === Parameters
    # options<Hash>: A hash containing :only and/or :except keys
    def check_unknown_options!(options = {})
      @check_unknown_options ||= {}
      options.each do |key, value|
        if value
          @check_unknown_options[key] = Array(value)
        else
          @check_unknown_options.delete(key)
        end
      end
      @check_unknown_options
    end

    # Overwrite check_unknown_options? to take subcommands and options into account.
    def check_unknown_options?(config) #:nodoc:
      options = check_unknown_options
      return false unless options

      command = config[:current_command]
      return true unless command

      name = command.name

      if subcommands.include?(name)
        false
      elsif options[:except]
        !options[:except].include?(name.to_sym)
      elsif options[:only]
        options[:only].include?(name.to_sym)
      else
        true
      end
    end

    # Stop parsing of options as soon as an unknown option or a regular
    # argument is encountered.  All remaining arguments are passed to the command.
    # This is useful if you have a command that can receive arbitrary additional
    # options, and where those additional options should not be handled by
    # Thor.
    #
    # ==== Example
    #
    # To better understand how this is useful, let's consider a command that calls
    # an external command.  A user may want to pass arbitrary options and
    # arguments to that command.  The command itself also accepts some options,
    # which should be handled by Thor.
    #
    #   class_option "verbose",  :type => :boolean
    #   stop_on_unknown_option! :exec
    #   check_unknown_options!  :except => :exec
    #
    #   desc "exec", "Run a shell command"
    #   def exec(*args)
    #     puts "diagnostic output" if options[:verbose]
    #     Kernel.exec(*args)
    #   end
    #
    # Here +exec+ can be called with +--verbose+ to get diagnostic output,
    # e.g.:
    #
    #   $ thor exec --verbose echo foo
    #   diagnostic output
    #   foo
    #
    # But if +--verbose+ is given after +echo+, it is passed to +echo+ instead:
    #
    #   $ thor exec echo --verbose foo
    #   --verbose foo
    #
    # ==== Parameters
    # Symbol ...:: A list of commands that should be affected.
    def stop_on_unknown_option!(*command_names)
      stop_on_unknown_option.merge(command_names)
    end

    def stop_on_unknown_option?(command) #:nodoc:
      command && stop_on_unknown_option.include?(command.name.to_sym)
    end

    # Disable the check for required options for the given commands.
    # This is useful if you have a command that does not need the required options
    # to work, like help.
    #
    # ==== Parameters
    # Symbol ...:: A list of commands that should be affected.
    def disable_required_check!(*command_names)
      disable_required_check.merge(command_names)
    end

    def disable_required_check?(command) #:nodoc:
      command && disable_required_check.include?(command.name.to_sym)
    end

  protected

    def stop_on_unknown_option #:nodoc:
      @stop_on_unknown_option ||= Set.new
    end

    # help command has the required check disabled by default.
    def disable_required_check #:nodoc:
      @disable_required_check ||= Set.new([:help])
    end

    # The method responsible for dispatching given the args.
    def dispatch(meth, given_args, given_opts, config) #:nodoc: # rubocop:disable MethodLength
      meth ||= retrieve_command_name(given_args)
      command = all_commands[normalize_command_name(meth)]

      if !command && config[:invoked_via_subcommand]
        # We're a subcommand and our first argument didn't match any of our
        # commands. So we put it back and call our default command.
        given_args.unshift(meth)
        command = all_commands[normalize_command_name(default_command)]
      end

      if command
        args, opts = Thor::Options.split(given_args)
        if stop_on_unknown_option?(command) && !args.empty?
          # given_args starts with a non-option, so we treat everything as
          # ordinary arguments
          args.concat opts
          opts.clear
        end
      else
        args = given_args
        opts = nil
        command = dynamic_command_class.new(meth)
      end

      opts = given_opts || opts || []
      config[:current_command] = command
      config[:command_options] = command.options

      instance = new(args, opts, config)
      yield instance if block_given?
      args = instance.args
      trailing = args[Range.new(arguments.size, -1)]
      instance.invoke_command(command, trailing || [])
    end

    # The banner for this class. You can customize it if you are invoking the
    # thor class by another ways which is not the Thor::Runner. It receives
    # the command that is going to be invoked and a boolean which indicates if
    # the namespace should be displayed as arguments.
    #
    def banner(command, namespace = nil, subcommand = false)
      "#{basename} #{command.formatted_usage(self, $thor_runner, subcommand)}"
    end

    def baseclass #:nodoc:
      Thor
    end

    def dynamic_command_class #:nodoc:
      Thor::DynamicCommand
    end

    def create_command(meth) #:nodoc:
      @usage ||= nil
      @desc ||= nil
      @long_desc ||= nil
      @hide ||= nil

      if @usage && @desc
        base_class = @hide ? Thor::HiddenCommand : Thor::Command
        commands[meth] = base_class.new(meth, @desc, @long_desc, @usage, method_options)
        @usage, @desc, @long_desc, @method_options, @hide = nil
        true
      elsif all_commands[meth] || meth == "method_missing"
        true
      else
        puts "[WARNING] Attempted to create command #{meth.inspect} without usage or description. " \
             "Call desc if you want this method to be available as command or declare it inside a " \
             "no_commands{} block. Invoked from #{caller[1].inspect}."
        false
      end
    end
    alias_method :create_task, :create_command

    def initialize_added #:nodoc:
      class_options.merge!(method_options)
      @method_options = nil
    end

    # Retrieve the command name from given args.
    def retrieve_command_name(args) #:nodoc:
      meth = args.first.to_s unless args.empty?
      args.shift if meth && (map[meth] || meth !~ /^\-/)
    end
    alias_method :retrieve_task_name, :retrieve_command_name

    # receives a (possibly nil) command name and returns a name that is in
    # the commands hash. In addition to normalizing aliases, this logic
    # will determine if a shortened command is an unambiguous substring of
    # a command or alias.
    #
    # +normalize_command_name+ also converts names like +animal-prison+
    # into +animal_prison+.
    def normalize_command_name(meth) #:nodoc:
      return default_command.to_s.tr("-", "_") unless meth

      possibilities = find_command_possibilities(meth)
      raise AmbiguousTaskError, "Ambiguous command #{meth} matches [#{possibilities.join(', ')}]" if possibilities.size > 1

      if possibilities.empty?
        meth ||= default_command
      elsif map[meth]
        meth = map[meth]
      else
        meth = possibilities.first
      end

      meth.to_s.tr("-", "_") # treat foo-bar as foo_bar
    end
    alias_method :normalize_task_name, :normalize_command_name

    # this is the logic that takes the command name passed in by the user
    # and determines whether it is an unambiguous substrings of a command or
    # alias name.
    def find_command_possibilities(meth)
      len = meth.to_s.length
      possibilities = all_commands.merge(map).keys.select { |n| meth == n[0, len] }.sort
      unique_possibilities = possibilities.map { |k| map[k] || k }.uniq

      if possibilities.include?(meth)
        [meth]
      elsif unique_possibilities.size == 1
        unique_possibilities
      else
        possibilities
      end
    end
    alias_method :find_task_possibilities, :find_command_possibilities

    def subcommand_help(cmd)
      desc "help [COMMAND]", "Describe subcommands or one specific subcommand"
      class_eval "
        def help(command = nil, subcommand = true); super; end
"
    end
    alias_method :subtask_help, :subcommand_help
  end

  include Thor::Base

  map HELP_MAPPINGS => :help

  desc "help [COMMAND]", "Describe available commands or one specific command"
  def help(command = nil, subcommand = false)
    if command
      if self.class.subcommands.include? command
        self.class.subcommand_classes[command].help(shell, true)
      else
        self.class.command_help(shell, command)
      end
    else
      self.class.help(shell, subcommand)
    end
  end
end
