# frozen_string_literal: true

module HamlLint
  # Bans the usage of “•” (bullet) in HTML/HAML in favor of “·” (middle dot) in anything that will end up as a text node. (including string literals in Ruby code)
  class Linter::MiddleDot < Linter
    include LinterRegistry

    # rubocop:disable Style/MiddleDot
    BULLET = '•'
    # rubocop:enable Style/MiddleDot
    MIDDLE_DOT = '·'
    MESSAGE = "Use '#{MIDDLE_DOT}' (middle dot) instead of '#{BULLET}' (bullet)".freeze

    def visit_plain(node)
      return unless node.text.include?(BULLET)

      record_lint(node, MESSAGE)
    end

    def visit_script(node)
      return unless node.script.include?(BULLET)

      record_lint(node, MESSAGE)
    end
  end
end
