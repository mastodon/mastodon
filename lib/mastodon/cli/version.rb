# frozen_string_literal: true

module Mastodon::CLI
  module Version
    extend ActiveSupport::Concern

    included do
      map %w(--version -v) => :version

      option :verbose, type: :boolean, aliases: [:v]
      desc 'version', 'Show version'
      def version
        if options[:verbose]
          print_table [
            %w(Software Version),
            *software_versions,
          ]
        else
          say(Mastodon::Version.to_s)
        end
      end

      private

      def software_versions
        Admin::Metrics::Dimension::SoftwareVersionsDimension
          .new(Date.current, Date.current, 0, {})
          .data
          .map { |data| [data[:human_key], data[:value]] }
      end
    end
  end
end
