# frozen_string_literal: true

module GroupCounters
  extend ActiveSupport::Concern

  ALLOWED_COUNTER_KEYS = %i(statuses_count members_count).freeze

  included do
    has_one :group_stat, inverse_of: :group
    after_save :save_group_stat
  end

  delegate :statuses_count,
           :statuses_count=,
           :members_count,
           :members_count=,
           :last_status_at,
           to: :group_stat

  # @param [Symbol] key
  def increment_count!(key)
    update_count!(key, 1)
  end

  # @param [Symbol] key
  def decrement_count!(key)
    update_count!(key, -1)
  end

  # @param [Symbol] key
  # @param [Integer] value
  def update_count!(key, value)
    raise ArgumentError, "Invalid key #{key}" unless ALLOWED_COUNTER_KEYS.include?(key)
    raise ArgumentError, 'Do not call update_count! on dirty objects' if association(:group_stat).loaded? && group_stat&.changed? && group_stat.changed_attribute_names_to_save == %w(id)

    value = value.to_i
    default_value = value.positive? ? value : 0

    # We do an upsert using manually written SQL, as Rails' upsert method does
    # not seem to support writing expressions in the UPDATE clause, but only
    # re-insert the provided values instead.
    # Even ARel seem to be missing proper handling of upserts.
    sql = if value.positive? && key == :statuses_count
            <<-SQL.squish
              INSERT INTO group_stats(group_id, #{key}, created_at, updated_at, last_status_at)
                VALUES (:group_id, :default_value, now(), now(), now())
              ON CONFLICT (group_id) DO UPDATE
              SET #{key} = group_stats.#{key} + :value,
                  last_status_at = now(),
                  updated_at = now()
              RETURNING id;
            SQL
          else
            <<-SQL.squish
              INSERT INTO group_stats(group_id, #{key}, created_at, updated_at)
                VALUES (:group_id, :default_value, now(), now())
              ON CONFLICT (group_id) DO UPDATE
              SET #{key} = group_stats.#{key} + :value,
                  updated_at = now()
              RETURNING id;
            SQL
          end

    sql = GroupStat.sanitize_sql([sql, group_id: id, default_value: default_value, value: value])
    group_stat_id = GroupStat.connection.exec_query(sql)[0]['id']

    # Reload group_stat if it was loaded, taking into newly-created unsaved group records
    if association(:group_stat).loaded?
      group_stat.id = group_stat_id if group_stat.new_record?
      group_stat.reload
    end
  end

  def group_stat
    super || build_group_stat
  end

  private

  def save_group_stat
    return unless association(:group_stat).loaded? && group_stat&.changed?

    group_stat.save
  end
end
