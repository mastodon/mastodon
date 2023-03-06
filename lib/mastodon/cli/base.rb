# frozen_string_literal: true

require_relative '../../../config/boot'
require_relative '../../../config/environment'

require 'thor'
require_relative 'helper'

module Mastodon
  module CLI
    class Base < Thor
      include CLI::Helper

      def self.exit_on_failure?
        true
      end
    end
  end
end
