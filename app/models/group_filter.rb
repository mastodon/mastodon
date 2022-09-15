# frozen_string_literal: true

class GroupFilter
  KEYS = %i(
    origin
    status
    by_domain
    display_name
    order
    by_member
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Group.includes(:group_stat).reorder(nil)

    params.each do |key, value|
      next if key.to_s == 'page'

      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'origin'
      origin_scope(value)
    when 'status'
      status_scope(value)
    when 'by_domain'
      Group.where(domain: value.to_s)
    when 'display_name'
      Group.matches_display_name(value.to_s)
    when 'by_member'
      Group.joins(:memberships).merge(GroupMembership.where(account_id: value.to_s))
    when 'order'
      order_scope(value)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def origin_scope(value)
    case value.to_s
    when 'local'
      Group.local
    when 'remote'
      Group.remote
    else
      raise "Unknown origin: #{value}"
    end
  end

  def status_scope(value)
    case value.to_s
    when 'active'
      Group.without_suspended
    when 'suspended'
      Group.suspended
    else
      raise "Unknown status: #{value}"
    end
  end

  def order_scope(value)
    case value.to_s
    when 'active'
      Group.left_joins(:group_stat).order(Arel.sql('coalesce(group_stats.last_status_at, to_timestamp(0)) desc, groups.id desc'))
    when 'recent'
      Group.recent
    else
      raise "Unknown order: #{value}"
    end
  end
end
