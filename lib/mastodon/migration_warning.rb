# frozen_string_literal: true

module Mastodon
  module MigrationWarning
    WARNING_SECONDS = 10

    DEFAULT_WARNING = <<~WARNING_MESSAGE
      WARNING: This migration may take a *long* time for large instances.
      It will *not* lock tables for any significant time, but it may run
      for a very long time. We will pause for #{WARNING_SECONDS} seconds to allow you to
      interrupt this migration if you are not ready.
    WARNING_MESSAGE

    def migration_duration_warning(explanation = nil)
      return unless valid_environment?

      announce_warning(explanation)

      announce_countdown
    end

    private

    def announce_countdown
      WARNING_SECONDS.downto(1) do |i|
        say "Continuing in #{i} second#{i == 1 ? '' : 's'}...", true
        sleep 1
      end
    end

    def valid_environment?
      $stdout.isatty
    end

    def announce_warning(explanation)
      announce_message prepare_message(explanation)
    end

    def announce_message(text)
      say ''
      text.each_line do |line|
        say(line)
      end
      say ''
    end

    def prepare_message(explanation)
      if explanation.blank?
        DEFAULT_WARNING
      else
        DEFAULT_WARNING + "\n#{explanation}"
      end
    end
  end
end
