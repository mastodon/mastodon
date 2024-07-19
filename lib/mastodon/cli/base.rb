# frozen_string_literal: true

require_relative '../../../config/boot'
require_relative '../../../config/environment'

require 'thor'
require 'pastel'
require_relative 'progress_helper'

module Mastodon
  module CLI
    class Base < Thor
      include ProgressHelper

      def self.exit_on_failure?
        true
      end

      private

      def fail_with_message(message)
        raise Thor::Error, message
      end

      def pastel
        @pastel ||= Pastel.new
      end

      def dry_run?
        options[:dry_run]
      end

      def dry_run_mode_suffix
        dry_run? ? ' (DRY RUN)' : ''
      end

      def reset_connection_pools!
        ActiveRecord::Base.establish_connection(
          ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first.configuration_hash
            .dup
            .tap { |config| config['pool'] = options[:concurrency] + 1 }
        )
        RedisConfiguration.establish_pool(options[:concurrency])
      end
    end
  end
end
