# frozen_string_literal: true

class AccountFilter
  KEYS = %i(
    origin
    status
    role_ids
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
    @params = params.to_h.symbolize_keys
  end

  def results
    scope = Account.includes(:account_stat, user: [:ips, :invite_request]).without_instance_actor.reorder(nil)

    relevant_params.each do |key, value|
      next if key.to_s == 'page'

      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def relevant_params
    params.tap do |args|
      args.delete(:origin) if origin_is_remote_and_domain_present?
    end
  end

  def origin_is_remote_and_domain_present?
    params[:origin] == 'remote' && params[:by_domain].present?
  end

  def scope_for(key, value)
    case key.to_s
    when 'origin'
      origin_scope(value)
    when 'role_ids'
      role_scope(value)
    when 'status'
      status_scope(value)
    when 'by_domain'
      Account.where(domain: value.to_s.strip)
    when 'username'
      Account.matches_username(value.to_s.strip.delete_prefix('@'))
    when 'display_name'
      Account.matches_display_name(value.to_s.strip)
    when 'email'
      accounts_with_users.merge(User.matches_email(value.to_s.strip))
    when 'ip'
      valid_ip?(value) ? accounts_with_users.merge(User.matches_ip(value).group('users.id, accounts.id')) : Account.none
    when 'invited_by'
      invited_by_scope(value)
    when 'order'
      order_scope(value)
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end

  def origin_scope(value)
    case value.to_s
    when 'local'
      Account.local
    when 'remote'
      Account.remote
    else
      raise Mastodon::InvalidParameterError, "Unknown origin: #{value}"
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
    when 'disabled'
      accounts_with_users.merge(User.disabled).without_suspended
    when 'silenced'
      Account.silenced
    when 'sensitized'
      Account.sensitized
    else
      raise Mastodon::InvalidParameterError, "Unknown status: #{value}"
    end
  end

  def order_scope(value)
    case value.to_s
    when 'active'
      Account.by_recent_activity
    when 'recent'
      Account.recent
    else
      raise Mastodon::InvalidParameterError, "Unknown order: #{value}"
    end
  end

  def invited_by_scope(value)
    Account.left_joins(user: :invite).merge(Invite.where(user_id: value.to_s))
  end

  def role_scope(value)
    accounts_with_users.merge(User.where(role_id: Array(value).map(&:to_s)))
  end

  def accounts_with_users
    Account.left_joins(:user)
  end

  def valid_ip?(value)
    IPAddr.new(value.to_s) && true
  rescue IPAddr::InvalidAddressError
    false
  end
end
