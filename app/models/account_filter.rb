# frozen_string_literal: true

class AccountFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Account.alphabetic
    params.each do |key, value|
      scope = scope.merge scope_for(key, value)
    end
    scope
  end

  def scope_for(key, value)
    case key
    when /local/
      Account.local
    when /remote/
      Account.remote
    when /by_domain/
      Account.where(domain: value)
    when /silenced/
      Account.silenced
    when /recent/
      Account.recent
    when /suspended/
      Account.suspended
    else
      raise "Unknown filter: #{key}"
    end
  end
end
