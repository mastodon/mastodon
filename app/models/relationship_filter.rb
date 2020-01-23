# frozen_string_literal: true

class RelationshipFilter
  KEYS = %i(
    relationship
    status
    by_domain
    activity
    order
    location
  ).freeze

  attr_reader :params, :account

  def initialize(account, params)
    @account = account
    @params  = params

    set_defaults!
  end

  def results
    scope = scope_for('relationship', params['relationship'])

    params.each do |key, value|
      next if key.to_s == 'page'

      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def set_defaults!
    params['relationship'] = 'following' if params['relationship'].blank?
    params['order']        = 'recent' if params['order'].blank?
  end

  def scope_for(key, value)
    case key.to_s
    when 'relationship'
      relationship_scope(value)
    when 'by_domain'
      by_domain_scope(value)
    when 'location'
      location_scope(value)
    when 'status'
      status_scope(value)
    when 'order'
      order_scope(value)
    when 'activity'
      activity_scope(value)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def relationship_scope(value)
    case value.to_s
    when 'following'
      account.following.eager_load(:account_stat).reorder(nil)
    when 'followed_by'
      account.followers.eager_load(:account_stat).reorder(nil)
    when 'mutual'
      account.followers.eager_load(:account_stat).reorder(nil).merge(Account.where(id: account.following))
    when 'invited'
      Account.joins(user: :invite).merge(Invite.where(user: account.user)).eager_load(:account_stat).reorder(nil)
    else
      raise "Unknown relationship: #{value}"
    end
  end

  def by_domain_scope(value)
    Account.where(domain: value.to_s)
  end

  def location_scope(value)
    case value.to_s
    when 'local'
      Account.local
    when 'remote'
      Account.remote
    else
      raise "Unknown location: #{value}"
    end
  end

  def status_scope(value)
    case value.to_s
    when 'moved'
      Account.where.not(moved_to_account_id: nil)
    when 'primary'
      Account.where(moved_to_account_id: nil)
    else
      raise "Unknown status: #{value}"
    end
  end

  def order_scope(value)
    case value.to_s
    when 'active'
      Account.by_recent_status
    when 'recent'
      Follow.recent
    else
      raise "Unknown order: #{value}"
    end
  end

  def activity_scope(value)
    case value.to_s
    when 'dormant'
      AccountStat.where(last_status_at: nil).or(AccountStat.where(AccountStat.arel_table[:last_status_at].lt(1.month.ago)))
    else
      raise "Unknown activity: #{value}"
    end
  end
end
