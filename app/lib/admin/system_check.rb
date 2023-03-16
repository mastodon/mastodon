# frozen_string_literal: true

class Admin::SystemCheck
  ACTIVE_CHECKS = [
    Admin::SystemCheck::MediaPrivacyCheck,
    Admin::SystemCheck::DatabaseSchemaCheck,
    Admin::SystemCheck::SidekiqProcessCheck,
    Admin::SystemCheck::RulesCheck,
    Admin::SystemCheck::ElasticsearchCheck,
  ].freeze

  def self.perform
    ACTIVE_CHECKS.each_with_object([]) do |klass, arr|
      check = klass.new

      if check.pass?
        arr
      else
        arr << check.message
      end
    end
  end
end
