# frozen_string_literal: true

class Admin::ServerCheck::RulesRunner
  include Admin::ServerCheck::Runner

  def authorized?(user)
    user.can?(:manage_rules)
  end

  def run
    severity = :warning

    Rule.kept.exists? ? ok(severity:) : pending(severity:)
  end
end
