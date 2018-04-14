# encoding: utf-8

require 'securerandom'
require 'shellwords'

module TTY
  class Command
    class Cmd
      # A string command name, or shell program
      # @api public
      attr_reader :command

      # A string arguments
      # @api public
      attr_reader :argv

      # Hash of operations to peform
      # @api public
      attr_reader :options

      # Unique identifier
      # @api public
      attr_reader :uuid

      # Initialize a new Cmd object
      #
      # @api private
      def initialize(env_or_cmd, *args)
        opts = args.last.respond_to?(:to_hash) ? args.pop : {}
        if env_or_cmd.respond_to?(:to_hash)
          @env = env_or_cmd
          unless command = args.shift
            raise ArgumentError, 'Cmd requires command argument'
          end
        else
          command = env_or_cmd
        end

        if args.empty? && cmd = command.to_s
          raise ArgumentError, 'No command provided' if cmd.empty?
          @command = sanitize(cmd)
          @argv = []
        else
          if command.respond_to?(:to_ary)
            @command = sanitize(command[0])
            args.unshift(*command[1..-1])
          else
            @command = sanitize(command)
          end
          @argv = args.map { |i| Shellwords.escape(i) }
        end
        @env ||= {}
        @options = opts

        @uuid = SecureRandom.uuid.split('-')[0]
        freeze
      end

      # Extend command options if keys don't already exist
      #
      # @api public
      def update(**options)
        @options.update(options.update(@options))
      end

      # The shell environment variables
      #
      # @api public
      def environment
        @env.merge(options.fetch(:env, {}))
      end

      def environment_string
        environment.map do |key, val|
          converted_key = key.is_a?(Symbol) ? key.to_s.upcase : key.to_s
          escaped_val = val.to_s.gsub(/"/, '\"')
          %(#{converted_key}="#{escaped_val}")
        end.join(' ')
      end

      def evars(value, &block)
        return (value || block) unless environment.any?
        %(( export #{environment_string} ; %s )) % [value || block.call]
      end

      def umask(value)
        return value unless options[:umask]
        %(umask #{options[:umask]} && %s) % [value]
      end

      def chdir(value)
        return value unless options[:chdir]
        %(cd #{options[:chdir]} && %s) % [value]
      end

      def user(value)
        return value unless options[:user]
        vars = environment.any? ? "#{environment_string} " : ''
        %(sudo -u #{options[:user]} #{vars}-- sh -c '%s') % [value]
      end

      def group(value)
        return value unless options[:group]
        %(sg #{options[:group]} -c \\\"%s\\\") % [value]
      end

      # Clear environment variables except specified by env
      #
      # @api public
      def with_clean_env
      end

      # Assemble full command
      #
      # @api public
      def to_command
        chdir(umask(evars(user(group(to_s)))))
      end

      # @api public
      def to_s
        [command.to_s, *Array(argv)].join(' ')
      end

      # @api public
      def to_hash
        {
          command: command,
          argv:    argv,
          uuid:    uuid
        }
      end

      private

      # Coerce to string
      #
      # @api private
      def sanitize(value)
        value.to_s.dup
      end
    end # Cmd
  end # Command
end # TTY
