# frozen_string_literal: true

class Admin::SystemCheck::RulesCheck < Admin::SystemCheck::BaseCheck
  include RoutingHelper

  def pass?
    Rule.kept.exists?
  end

  def message
    Admin::SystemCheck::Message.new(:rules_check, nil, admin_rules_path)
  end
end
