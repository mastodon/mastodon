# frozen_string_literal: true

class GroupMembershipFilter
  KEYS = %i(
    status
    by_domain
    order
    location
  ).freeze

  attr_reader :params, :group

  def initialize(group, params)
    @group = group
    @params  = params

    set_defaults!
  end

  def results
    scope = @group.members.eager_load(:account_stat).reorder(nil)

    params.each do |key, value|
      next if %w(page).include?(key)

      scope.merge!(scope_for(key.to_s, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def set_defaults!
    params['order'] = 'recent' if params['order'].blank?
  end

  def scope_for(key, value)
    case key
    when 'by_domain'
      by_domain_scope(value)
    when 'location'
      location_scope(value)
    when 'status'
      status_scope(value)
    when 'order'
      order_scope(value)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def by_domain_scope(value)
    Account.where(domain: value)
  end

  def location_scope(value)
    case value
    when 'local'
      Account.local
    when 'remote'
      Account.remote
    else
      raise "Unknown location: #{value}"
    end
  end

  def status_scope(value)
    case value
    when 'moved'
      Account.where.not(moved_to_account_id: nil)
    when 'primary'
      Account.where(moved_to_account_id: nil)
    else
      raise "Unknown status: #{value}"
    end
  end

  def order_scope(value)
    case value
    when 'active'
      Account.by_recent_status
    when 'recent'
      GroupMembership.recent
    else
      raise "Unknown order: #{value}"
    end
  end
end
