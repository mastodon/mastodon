# coding: UTF-8

require 'climate_control'

module Cocaine
  class CommandLine
    class BackticksRunner
      def self.supported?
        true
      end

      def supported?
        self.class.supported?
      end

      def call(command, env = {}, options = {})
        with_modified_environment(env) do
          Output.new(`#{command}`)
        end
      end

      private

      def with_modified_environment(env, &block)
        ClimateControl.modify(env, &block)
      end

    end
  end
end
