# encoding: utf-8
# frozen_string_literal: true

require 'pastel'

require_relative 'abstract'

module TTY
  class Command
    module Printers
      class Pretty < Abstract
        TIME_FORMAT = "%5.3f %s".freeze

        def print_command_start(cmd, *args)
          message = ["Running #{decorate(cmd.to_command, :yellow, :bold)}"]
          message << args.map(&:chomp).join(' ') unless args.empty?
          write(message.join, cmd.uuid)
        end

        def print_command_out_data(cmd, *args)
          message = args.map(&:chomp).join(' ')
          write("\t#{message}", cmd.uuid)
        end

        def print_command_err_data(cmd, *args)
          message = args.map(&:chomp).join(' ')
          write("\t" + decorate(message, :red), cmd.uuid)
        end

        def print_command_exit(cmd, status, runtime, *args)
          runtime = TIME_FORMAT % [runtime, pluralize(runtime, 'second')]
          message = ["Finished in #{runtime}"]
          message << " with exit status #{status}" if status
          message << " (#{success_or_failure(status)})"
          write(message.join, cmd.uuid)
        end

        # Write message out to output
        #
        # @api private
        def write(message, uuid = nil)
          uuid_needed = options.fetch(:uuid) { true }
          out = []
          if uuid_needed
            out << "[#{decorate(uuid, :green)}] " unless uuid.nil?
          end
          out << "#{message}\n"
          output << out.join
        end

        private

        # Pluralize word based on a count
        #
        # @api private
        def pluralize(count, word)
          "#{word}#{'s' unless count.to_f == 1}"
        end

        # @api private
        def success_or_failure(status)
          if status == 0
            decorate('successful', :green, :bold)
          else
            decorate('failed', :red, :bold)
          end
        end
      end # Pretty
    end # Printers
  end # Command
end # TTY
