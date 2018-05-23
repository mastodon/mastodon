require "thor/base"

# Thor has a special class called Thor::Group. The main difference to Thor class
# is that it invokes all commands at once. It also include some methods that allows
# invocations to be done at the class method, which are not available to Thor
# commands.
class Thor::Group
  class << self
    # The description for this Thor::Group. If none is provided, but a source root
    # exists, tries to find the USAGE one folder above it, otherwise searches
    # in the superclass.
    #
    # ==== Parameters
    # description<String>:: The description for this Thor::Group.
    #
    def desc(description = nil)
      if description
        @desc = description
      else
        @desc ||= from_superclass(:desc, nil)
      end
    end

    # Prints help information.
    #
    # ==== Options
    # short:: When true, shows only usage.
    #
    def help(shell)
      shell.say "Usage:"
      shell.say "  #{banner}\n"
      shell.say
      class_options_help(shell)
      shell.say desc if desc
    end

    # Stores invocations for this class merging with superclass values.
    #
    def invocations #:nodoc:
      @invocations ||= from_superclass(:invocations, {})
    end

    # Stores invocation blocks used on invoke_from_option.
    #
    def invocation_blocks #:nodoc:
      @invocation_blocks ||= from_superclass(:invocation_blocks, {})
    end

    # Invoke the given namespace or class given. It adds an instance
    # method that will invoke the klass and command. You can give a block to
    # configure how it will be invoked.
    #
    # The namespace/class given will have its options showed on the help
    # usage. Check invoke_from_option for more information.
    #
    def invoke(*names, &block)
      options = names.last.is_a?(Hash) ? names.pop : {}
      verbose = options.fetch(:verbose, true)

      names.each do |name|
        invocations[name] = false
        invocation_blocks[name] = block if block_given?

        class_eval <<-METHOD, __FILE__, __LINE__
          def _invoke_#{name.to_s.gsub(/\W/, '_')}
            klass, command = self.class.prepare_for_invocation(nil, #{name.inspect})

            if klass
              say_status :invoke, #{name.inspect}, #{verbose.inspect}
              block = self.class.invocation_blocks[#{name.inspect}]
              _invoke_for_class_method klass, command, &block
            else
              say_status :error, %(#{name.inspect} [not found]), :red
            end
          end
        METHOD
      end
    end

    # Invoke a thor class based on the value supplied by the user to the
    # given option named "name". A class option must be created before this
    # method is invoked for each name given.
    #
    # ==== Examples
    #
    #   class GemGenerator < Thor::Group
    #     class_option :test_framework, :type => :string
    #     invoke_from_option :test_framework
    #   end
    #
    # ==== Boolean options
    #
    # In some cases, you want to invoke a thor class if some option is true or
    # false. This is automatically handled by invoke_from_option. Then the
    # option name is used to invoke the generator.
    #
    # ==== Preparing for invocation
    #
    # In some cases you want to customize how a specified hook is going to be
    # invoked. You can do that by overwriting the class method
    # prepare_for_invocation. The class method must necessarily return a klass
    # and an optional command.
    #
    # ==== Custom invocations
    #
    # You can also supply a block to customize how the option is going to be
    # invoked. The block receives two parameters, an instance of the current
    # class and the klass to be invoked.
    #
    def invoke_from_option(*names, &block)
      options = names.last.is_a?(Hash) ? names.pop : {}
      verbose = options.fetch(:verbose, :white)

      names.each do |name|
        unless class_options.key?(name)
          raise ArgumentError, "You have to define the option #{name.inspect} " \
                              "before setting invoke_from_option."
        end

        invocations[name] = true
        invocation_blocks[name] = block if block_given?

        class_eval <<-METHOD, __FILE__, __LINE__
          def _invoke_from_option_#{name.to_s.gsub(/\W/, '_')}
            return unless options[#{name.inspect}]

            value = options[#{name.inspect}]
            value = #{name.inspect} if TrueClass === value
            klass, command = self.class.prepare_for_invocation(#{name.inspect}, value)

            if klass
              say_status :invoke, value, #{verbose.inspect}
              block = self.class.invocation_blocks[#{name.inspect}]
              _invoke_for_class_method klass, command, &block
            else
              say_status :error, %(\#{value} [not found]), :red
            end
          end
        METHOD
      end
    end

    # Remove a previously added invocation.
    #
    # ==== Examples
    #
    #   remove_invocation :test_framework
    #
    def remove_invocation(*names)
      names.each do |name|
        remove_command(name)
        remove_class_option(name)
        invocations.delete(name)
        invocation_blocks.delete(name)
      end
    end

    # Overwrite class options help to allow invoked generators options to be
    # shown recursively when invoking a generator.
    #
    def class_options_help(shell, groups = {}) #:nodoc:
      get_options_from_invocations(groups, class_options) do |klass|
        klass.send(:get_options_from_invocations, groups, class_options)
      end
      super(shell, groups)
    end

    # Get invocations array and merge options from invocations. Those
    # options are added to group_options hash. Options that already exists
    # in base_options are not added twice.
    #
    def get_options_from_invocations(group_options, base_options) #:nodoc: # rubocop:disable MethodLength
      invocations.each do |name, from_option|
        value = if from_option
          option = class_options[name]
          option.type == :boolean ? name : option.default
        else
          name
        end
        next unless value

        klass, _ = prepare_for_invocation(name, value)
        next unless klass && klass.respond_to?(:class_options)

        value = value.to_s
        human_name = value.respond_to?(:classify) ? value.classify : value

        group_options[human_name] ||= []
        group_options[human_name] += klass.class_options.values.select do |class_option|
          base_options[class_option.name.to_sym].nil? && class_option.group.nil? &&
            !group_options.values.flatten.any? { |i| i.name == class_option.name }
        end

        yield klass if block_given?
      end
    end

    # Returns commands ready to be printed.
    def printable_commands(*)
      item = []
      item << banner
      item << (desc ? "# #{desc.gsub(/\s+/m, ' ')}" : "")
      [item]
    end
    alias_method :printable_tasks, :printable_commands

    def handle_argument_error(command, error, _args, arity) #:nodoc:
      msg = "#{basename} #{command.name} takes #{arity} argument".dup
      msg << "s" if arity > 1
      msg << ", but it should not."
      raise error, msg
    end

  protected

    # The method responsible for dispatching given the args.
    def dispatch(command, given_args, given_opts, config) #:nodoc:
      if Thor::HELP_MAPPINGS.include?(given_args.first)
        help(config[:shell])
        return
      end

      args, opts = Thor::Options.split(given_args)
      opts = given_opts || opts

      instance = new(args, opts, config)
      yield instance if block_given?

      if command
        instance.invoke_command(all_commands[command])
      else
        instance.invoke_all
      end
    end

    # The banner for this class. You can customize it if you are invoking the
    # thor class by another ways which is not the Thor::Runner.
    def banner
      "#{basename} #{self_command.formatted_usage(self, false)}"
    end

    # Represents the whole class as a command.
    def self_command #:nodoc:
      Thor::DynamicCommand.new(namespace, class_options)
    end
    alias_method :self_task, :self_command

    def baseclass #:nodoc:
      Thor::Group
    end

    def create_command(meth) #:nodoc:
      commands[meth.to_s] = Thor::Command.new(meth, nil, nil, nil, nil)
      true
    end
    alias_method :create_task, :create_command
  end

  include Thor::Base

protected

  # Shortcut to invoke with padding and block handling. Use internally by
  # invoke and invoke_from_option class methods.
  def _invoke_for_class_method(klass, command = nil, *args, &block) #:nodoc:
    with_padding do
      if block
        case block.arity
        when 3
          yield(self, klass, command)
        when 2
          yield(self, klass)
        when 1
          instance_exec(klass, &block)
        end
      else
        invoke klass, command, *args
      end
    end
  end
end
