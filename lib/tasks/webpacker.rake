# frozen_string_literal: true

# Disable this task as we use pnpm

require 'semantic_range'

Rake::Task['webpacker:check_yarn'].clear

namespace :webpacker do
  desc 'Verifies if Yarn is installed'
  task check_yarn: :environment do
    begin
      yarn_version = `yarn --version`.strip
      raise Errno::ENOENT if yarn_version.blank?

      yarn_range = '>=4 <5'
      is_valid = begin
        SemanticRange.satisfies?(yarn_version, yarn_range)
      rescue
        false
      end

      unless is_valid
        warn "Mastodon and Webpacker requires Yarn \"#{yarn_range}\" and you are using #{yarn_version}"
        warn 'Exiting!'
        exit!
      end
    rescue Errno::ENOENT
      warn 'Yarn not installed. Please see the Mastodon documentation to install the correct version.'
      warn 'Exiting!'
      exit!
    end
  end
end
