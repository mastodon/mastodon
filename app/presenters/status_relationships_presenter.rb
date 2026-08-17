# frozen_string_literal: true

class StatusRelationshipsPresenter
  PINNABLE_VISIBILITIES = %w(public unlisted private).freeze

  attr_reader :reblogs_map, :favourites_map, :mutes_map, :pins_map,
              :bookmarks_map, :filters_map, :attributes_map

  def initialize(statuses, current_account_id = nil, **options)
    @current_account_id = current_account_id

    # Keeping a reference to @statuses is ok since `StatusRelationshipsPresenter`
    # basically never outlives the statuses collection it is passed
    @statuses = statuses

    if current_account_id.nil?
      @preloaded_account_relations = {}
      @filters_map     = {}
      @reblogs_map     = {}
      @favourites_map  = {}
      @bookmarks_map   = {}
      @mutes_map       = {}
      @pins_map        = {}
      @attributes_map  = {}
    else
      @preloaded_account_relations = nil

      statuses            = statuses.compact
      status_ids          = statuses.flat_map { |s| [s.id, s.reblog_of_id, s.proper.quote&.quoted_status_id] }.uniq.compact
      conversation_ids    = statuses.flat_map { |s| [s.proper.conversation_id, s.proper.quote&.quoted_status&.conversation_id] }.uniq.compact
      pinnable_status_ids = statuses.flat_map { |s| [s.proper, s.proper.quote&.quoted_status] }.compact.filter_map { |s| s.id if s.account_id == current_account_id && PINNABLE_VISIBILITIES.include?(s.visibility) }

      @filters_map     = build_filters_map(statuses.flat_map { |s| [s, s.proper.quote&.quoted_status] }.compact.uniq, current_account_id).merge(options[:filters_map] || {})
      @reblogs_map     = Status.reblogs_map(status_ids, current_account_id).merge(options[:reblogs_map] || {})
      @favourites_map  = Status.favourites_map(status_ids, current_account_id).merge(options[:favourites_map] || {})
      @bookmarks_map   = Status.bookmarks_map(status_ids, current_account_id).merge(options[:bookmarks_map] || {})
      @mutes_map       = Status.mutes_map(conversation_ids, current_account_id).merge(options[:mutes_map] || {})
      @pins_map        = Status.pins_map(pinnable_status_ids, current_account_id).merge(options[:pins_map] || {})
      @attributes_map  = options[:attributes_map] || {}
    end
  end

  # This one is currently on-demand as it is only used for quote posts
  def authoring_accounts
    @authoring_accounts ||= @statuses.compact.flat_map { |s| [s.account, s.proper.account, s.proper.quote&.quoted_account] }.uniq.compact
  end

  private

  def build_filters_map(statuses, current_account_id)
    active_filters = CustomFilter.cached_filters_for(current_account_id)

    @filters_map = statuses.each_with_object({}) do |status, h|
      filter_matches = CustomFilter.apply_cached_filters(active_filters, status)

      unless filter_matches.empty?
        h[status.id] = filter_matches
        h[status.reblog_of_id] = filter_matches if status.reblog?
      end
    end
  end
end
