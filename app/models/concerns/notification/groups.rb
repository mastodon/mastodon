# frozen_string_literal: true

module Notification::Groups
  extend ActiveSupport::Concern

  # `set_group_key!` needs to be updated if this list changes
  GROUPABLE_NOTIFICATION_TYPES = %i(favourite reblog follow admin.sign_up).freeze
  MAXIMUM_GROUP_SPAN_HOURS = 12

  included do
    scope :by_group_key, ->(group_key) { group_key&.start_with?('ungrouped-') ? where(id: group_key.delete_prefix('ungrouped-')) : where(group_key: group_key) }
  end

  def set_group_key!
    return if filtered? || GROUPABLE_NOTIFICATION_TYPES.exclude?(type)

    type_prefix = case type
                  when :favourite, :reblog
                    [type, target_status&.id].join('-')
                  when :follow, :'admin.sign_up'
                    type
                  else
                    raise NotImplementedError
                  end
    redis_key   = "notif-group/#{account.id}/#{type_prefix}"
    hour_bucket = activity.created_at.utc.to_i / 1.hour.to_i

    # Reuse previous group if it does not span too large an amount of time
    previous_bucket = redis.get(redis_key).to_i
    hour_bucket = previous_bucket if hour_bucket < previous_bucket + MAXIMUM_GROUP_SPAN_HOURS

    # We do not concern ourselves with race conditions since we use hour buckets
    redis.set(redis_key, hour_bucket, ex: MAXIMUM_GROUP_SPAN_HOURS.hours.to_i)

    self.group_key = "#{type_prefix}-#{hour_bucket}"
  end

  class_methods do
    def paginate_groups(limit, pagination_order, grouped_types: nil)
      raise ArgumentError unless %i(asc desc).include?(pagination_order)

      query = reorder(id: pagination_order)

      # Ideally `:types` would be a bind rather than part of the SQL itself, but that does not
      # seem to be possible to do with Rails, considering that the expression would occur in
      # multiple places, including in a `select`
      group_key_sql = begin
        if grouped_types.present?
          # Normalize `grouped_types` so the number of different SQL query shapes remains small, and
          # the queries can be analyzed in monitoring/telemetry tools
          grouped_types = (grouped_types.map(&:to_sym) & GROUPABLE_NOTIFICATION_TYPES).sort

          sanitize_sql_array([<<~SQL.squish, { types: grouped_types }])
            COALESCE(
              CASE
                WHEN notifications.type IN (:types) THEN notifications.group_key
                ELSE NULL
              END,
              'ungrouped-' || notifications.id
            )
          SQL
        else
          "COALESCE(notifications.group_key, 'ungrouped-' || notifications.id)"
        end
      end

      unscoped
        .with_recursive(
          grouped_notifications: [
            # Base case: fetching one notification and annotating it with visited groups
            query
              .select('notifications.*', "ARRAY[#{group_key_sql}] AS groups")
              .limit(1),
            # Recursive case, always yielding at most one annotated notification
            unscoped
              .from(
                [
                  # Expose the working table as `wt`, but quit early if we've reached the limit
                  unscoped
                    .select('id', 'groups')
                    .from('grouped_notifications')
                    .where('array_length(grouped_notifications.groups, 1) < :limit', limit: limit)
                    .arel.as('wt'),
                  # Recursive query, using `LATERAL` so we can refer to `wt`
                  query
                    .where(pagination_order == :desc ? 'notifications.id < wt.id' : 'notifications.id > wt.id')
                    .where.not("#{group_key_sql} = ANY(wt.groups)")
                    .limit(1)
                    .arel.lateral('notifications'),
                ]
              )
              .select('notifications.*', "array_append(wt.groups, #{group_key_sql}) AS groups"),
          ]
        )
        .from('grouped_notifications AS notifications')
        .order(id: pagination_order)
        .limit(limit)
    end

    # This returns notifications from the request page, but with at most one notification per group.
    # Notifications that have no `group_key` each count as a separate group.
    def paginate_groups_by_max_id(limit, max_id: nil, since_id: nil, grouped_types: nil)
      query = reorder(id: :desc)
      query = query.where(id: ...(max_id.to_i)) if max_id.present?
      query = query.where(id: (since_id.to_i + 1)...) if since_id.present?
      query.paginate_groups(limit, :desc, grouped_types: grouped_types)
    end

    # Differs from :paginate_groups_by_max_id in that it gives the results immediately following min_id,
    # whereas since_id gives the items with largest id, but with since_id as a cutoff.
    # Results will be in ascending order by id.
    def paginate_groups_by_min_id(limit, max_id: nil, min_id: nil, grouped_types: nil)
      query = reorder(id: :asc)
      query = query.where(id: (min_id.to_i + 1)...) if min_id.present?
      query = query.where(id: ...(max_id.to_i)) if max_id.present?
      query.paginate_groups(limit, :asc, grouped_types: grouped_types)
    end

    def to_a_grouped_paginated_by_id(limit, options = {})
      if options[:min_id].present?
        paginate_groups_by_min_id(limit, min_id: options[:min_id], max_id: options[:max_id], grouped_types: options[:grouped_types]).reverse
      else
        paginate_groups_by_max_id(limit, max_id: options[:max_id], since_id: options[:since_id], grouped_types: options[:grouped_types]).to_a
      end
    end
  end
end
