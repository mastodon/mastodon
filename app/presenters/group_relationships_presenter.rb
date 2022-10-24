# frozen_string_literal: true

class GroupRelationshipsPresenter
  attr_reader :member, :requested

  def initialize(group_ids, current_account_id, **options)
    @group_ids       = group_ids.map { |g| g.is_a?(Group) ? g.id : g.to_i }
    @current_account_id = current_account_id

    @member = cached[:member].merge(Group.member_map(@uncached_group_ids, @current_account_id))
    @requested = cached[:requested].merge(Group.requested_map(@uncached_group_ids, @current_account_id))

    cache_uncached!

    @member.merge!(options[:member_map] || {})
    @requested.merge!(options[:requested_map] || {})
  end

  private

  def cached
    return @cached if defined?(@cached)

    @cached = {
      member: {},
      requested: {},
    }

    @uncached_group_ids = []

    @group_ids.each do |group_id|
      maps_for_account = Rails.cache.read("group_relationship:#{@current_account_id}:#{group_id}")

      if maps_for_account.is_a?(Hash)
        @cached.deep_merge!(maps_for_account)
      else
        @uncached_group_ids << group_id
      end
    end

    @cached
  end

  def cache_uncached!
    @uncached_group_ids.each do |group_id|
      maps_for_account = {
        member: { group_id => member[group_id] },
        requested: { group_id => requested[group_id] },
      }

      Rails.cache.write("group_relationship:#{@current_account_id}:#{group_id}", maps_for_account, expires_in: 1.day)
    end
  end
end
