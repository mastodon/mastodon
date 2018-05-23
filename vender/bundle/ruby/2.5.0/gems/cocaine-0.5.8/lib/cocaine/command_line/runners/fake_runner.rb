# coding: UTF-8

module Cocaine
  class CommandLine
    class FakeRunner
      def self.supported?
        false
      end

      def supported?
        self.class.supported?
      end

      attr_reader :commands

      def initialize
        @commands = []
      end

      def call(command, env = {}, options = {})
        commands << [command, env]
        Output.new("")
      end

      def ran?(predicate_command)
        @commands.any?{|(command, _)| command =~ Regexp.new(predicate_command) }
      end
    end
  end
end
