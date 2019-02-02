# frozen_string_literal: true

class AccountFilter
  attr_reader :params

  def initialize(params)
    @params = params
    set_defaults!
  end

  def results
    scope = Account.recent.includes(:user)

    params.each do |key, value|
      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def set_defaults!
    params['local']  = '1' if params['remote'].blank?
    params['active'] = '1' if params['suspended'].blank? && params['silenced'].blank?
  end

  def scope_for(key, value)
    case key.to_s
    when 'local'
      Account.local
    when 'remote'
      Account.remote
    when 'by_domain'
      Account.where(domain: value)
    when 'active'
      Account.without_suspended
    when 'silenced'
      Account.silenced
    when 'suspended'
      Account.suspended
    when 'username'
      Account.matches_username(value)
    when 'display_name'
      Account.matches_display_name(value)
    when 'email'
      accounts_with_users.merge User.matches_email(value)
    when 'ip'
      valid_ip?(value) ? accounts_with_users.where('users.current_sign_in_ip <<= ?', value) : Account.none
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
    IPAddr.new(value) && true
  rescue IPAddr::InvalidAddressError
    false
  end
end
