# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Bans the usage of “•” (bullet) in HTML/HAML in favor of “·” (middle dot) in string literals
      class MiddleDot < Base
        extend AutoCorrector
        extend Util

        # rubocop:disable Style/MiddleDot
        BULLET = '•'
        # rubocop:enable Style/MiddleDot
        MIDDLE_DOT = '·'
        MESSAGE = "Use '#{MIDDLE_DOT}' (middle dot) instead of '#{BULLET}' (bullet)".freeze

        def on_str(node)
          # Constants like __FILE__ are handled as strings,
          # but don't respond to begin.
          return unless node.loc.respond_to?(:begin) && node.loc.begin

          return unless node.value.include?(BULLET)

          add_offense(node, message: MESSAGE) do |corrector|
            corrector.replace(node, node.source.gsub(BULLET, MIDDLE_DOT))
          end
        end
      end
    end
  end
end
