# frozen_string_literal: true

class UserFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = User.all
    params.each do |key, value|
      scope = scope.merge scope_for(key, value)
    end
    scope
  end

  def scope_for(key, value)
    case key
    when /admin/
      User.admins
    when /\Aconfirmed/
      User.confirmed
    when /unconfirmed/
      User.unconfirmed
    else
      raise "Unknown filter: #{key}"
    end
  end
end
