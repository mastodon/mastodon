# frozen_string_literal: true

class AccountFilter
  KEYS = %i(
    origin
    status
    permissions
    username
    by_domain
    display_name
    email
    ip
    invited_by
    order
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Account.includes(:account_stat, user: [:ips, :invite_request]).without_instance_actor.reorder(nil)

    params.each do |key, value|
      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'origin'
      origin_scope(value)
    when 'permissions'
      permissions_scope(value)
    when 'status'
      status_scope(value)
    when 'by_domain'
      Account.where(domain: value)
    when 'username'
      Account.matches_username(value)
    when 'display_name'
      Account.matches_display_name(value)
    when 'email'
      accounts_with_users.merge(User.matches_email(value))
    when 'ip'
      valid_ip?(value) ? accounts_with_users.merge(User.matches_ip(value)) : Account.none
    when 'invited_by'
      invited_by_scope(value)
    when 'order'
      order_scope(value)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def origin_scope(value)
    case value.to_s
    when 'local'
      Account.local
    when 'remote'
      Account.remote
    else
      raise "Unknown origin: #{value}"
    end
  end

  def status_scope(value)
    case value.to_s
    when 'active'
      Account.without_suspended
    when 'pending'
      accounts_with_users.merge(User.pending)
    when 'suspended'
      Account.suspended
    else
      raise "Unknown status: #{value}"
    end
  end

  def order_scope(value)
    case value.to_s
    when 'active'
      accounts_with_users.left_joins(:account_stat).order(Arel.sql('coalesce(users.current_sign_in_at, account_stats.last_status_at, to_timestamp(0)) desc, accounts.id desc'))
    when 'recent'
      Account.recent
    else
      raise "Unknown order: #{value}"
    end
  end

  def invited_by_scope(value)
    Account.left_joins(user: :invite).merge(Invite.where(user_id: value.to_s))
  end

  def permissions_scope(value)
    case value.to_s
    when 'staff'
      accounts_with_users.merge(User.staff)
    else
      raise "Unknown permissions: #{value}"
    end
  end

  def accounts_with_users
    Account.left_joins(:user)
  end

  def valid_ip?(value)
    IPAddr.new(value) && true
  rescue IPAddr::InvalidAddressError
    false
  end
end
