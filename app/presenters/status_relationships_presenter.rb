# frozen_string_literal: true

class StatusRelationshipsPresenter
  attr_reader :reblogs_map, :favourites_map, :mutes_map, :pins_map,
              :bookmarks_map

  def initialize(statuses, current_account_id = nil, **options)
    if current_account_id.nil?
      @reblogs_map    = {}
      @favourites_map = {}
      @bookmarks_map  = {}
      @mutes_map      = {}
      @pins_map       = {}
    else
      statuses            = statuses.compact
      status_ids          = statuses.flat_map { |s| [s.id, s.reblog_of_id] }.uniq.compact
      conversation_ids    = statuses.map(&:conversation_id).compact.uniq
      pinnable_status_ids = statuses.map(&:proper).select { |s| s.account_id == current_account_id && %w(public unlisted).include?(s.visibility) }.map(&:id)

      @reblogs_map     = Status.reblogs_map(status_ids, current_account_id).merge(options[:reblogs_map] || {})
      @favourites_map  = Status.favourites_map(status_ids, current_account_id).merge(options[:favourites_map] || {})
      @bookmarks_map   = Status.bookmarks_map(status_ids, current_account_id).merge(options[:bookmarks_map] || {})
      @mutes_map       = Status.mutes_map(conversation_ids, current_account_id).merge(options[:mutes_map] || {})
      @pins_map        = Status.pins_map(pinnable_status_ids, current_account_id).merge(options[:pins_map] || {})
    end
  end
end
