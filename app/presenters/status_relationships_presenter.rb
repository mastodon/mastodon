# frozen_string_literal: true

class StatusRelationshipsPresenter
  attr_reader :reblogs_map, :favourites_map, :mutes_map

  def initialize(statuses, current_account_id = nil, reblogs_map: {}, favourites_map: {}, mutes_map: {})
    if current_account_id.nil?
      @reblogs_map    = {}
      @favourites_map = {}
      @mutes_map      = {}
    else
      status_ids       = statuses.compact.flat_map { |s| [s.id, s.reblog_of_id] }.uniq
      conversation_ids = statuses.compact.map(&:conversation_id).compact.uniq
      @reblogs_map     = Status.reblogs_map(status_ids, current_account_id).merge(reblogs_map)
      @favourites_map  = Status.favourites_map(status_ids, current_account_id).merge(favourites_map)
      @mutes_map       = Status.mutes_map(conversation_ids, current_account_id).merge(mutes_map)
    end
  end
end
