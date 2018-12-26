# frozen_string_literal: true

class AccountFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Account.alphabetic

    params.each do |key, value|
      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'local'
      Account.local
    when 'remote'
      Account.remote
    when 'by_domain'
      Account.where(domain: value)
    when 'silenced'
      Account.silenced
    when 'recent'
      Account.recent
    when 'suspended'
      Account.suspended
    when 'username'
      Account.matches_username(value)
    when 'display_name'
      Account.matches_display_name(value)
    when 'email'
      accounts_with_users.merge User.matches_email(value)
    when 'ip'
      if valid_ip?(value)
        accounts_with_users.merge User.with_recent_ip_address(value)
      else
        Account.default_scoped
      end
    when 'staff'
      accounts_with_users.merge User.staff
    else
      raise "Unknown filter: #{key}"
    end
  end

  def accounts_with_users
    Account.joins(:user)
  end

  def valid_ip?(value)
    IPAddr.new(value)
    true
  rescue IPAddr::InvalidAddressError
    false
  end
end
