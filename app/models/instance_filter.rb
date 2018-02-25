# frozen_string_literal: true

class InstanceFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Account.remote.by_domain_accounts
    params.each do |key, value|
      scope.merge!(scope_for(key, value)) if value.present?
    end
    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'domain_name'
      Account.matches_domain(value)
    else
      raise "Unknown filter: #{key}"
    end
  end
end
