# encoding: utf-8
# frozen_string_literal: true

require_relative 'result'

module TTY
  class Command
    class DryRunner
      attr_reader :cmd

      def initialize(cmd, printer)
        @cmd     = cmd
        @printer = printer
      end

      # Show command without running
      #
      # @api public
      def run!(*)
        cmd.to_command
        message = "#{@printer.decorate('(dry run)', :blue)} " +
                  @printer.decorate(cmd.to_command, :yellow, :bold)
        @printer.write(message, cmd.uuid)
        Result.new(0, '', '')
      end
    end # DryRunner
  end # Command
end # TTY
