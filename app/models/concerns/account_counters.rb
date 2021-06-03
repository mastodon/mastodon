# frozen_string_literal: true

module AccountCounters
  extend ActiveSupport::Concern

  ALLOWED_COUNTER_KEYS = %i(statuses_count following_count followers_count).freeze

  included do
    has_one :account_stat, inverse_of: :account
    after_save :save_account_stat
  end

  delegate :statuses_count,
           :statuses_count=,
           :following_count,
           :following_count=,
           :followers_count,
           :followers_count=,
           :last_status_at,
           to: :account_stat

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
    raise ArgumentError, 'Do not call update_count! on dirty objects' if association(:account_stat).loaded? && account_stat&.changed? && account_stat.changed_attribute_names_to_save == %w(id)

    value = value.to_i
    default_value = value.positive? ? value : 0

    # We do an upsert using manually written SQL, as Rails' upsert method does
    # not seem to support writing expressions in the UPDATE clause, but only
    # re-insert the provided values instead.
    # Even ARel seem to be missing proper handling of upserts.
    sql = if value.positive? && key == :statuses_count
            <<-SQL.squish
              INSERT INTO account_stats(account_id, #{key}, created_at, updated_at, last_status_at)
                VALUES (:account_id, :default_value, now(), now(), now())
              ON CONFLICT (account_id) DO UPDATE
              SET #{key} = account_stats.#{key} + :value,
                  last_status_at = now(),
                  updated_at = now()
              RETURNING id;
            SQL
          else
            <<-SQL.squish
              INSERT INTO account_stats(account_id, #{key}, created_at, updated_at)
                VALUES (:account_id, :default_value, now(), now())
              ON CONFLICT (account_id) DO UPDATE
              SET #{key} = account_stats.#{key} + :value,
                  updated_at = now()
              RETURNING id;
            SQL
          end

    sql = AccountStat.sanitize_sql([sql, account_id: id, default_value: default_value, value: value])
    account_stat_id = AccountStat.connection.exec_query(sql)[0]['id']

    # Reload account_stat if it was loaded, taking into account newly-created unsaved records
    if association(:account_stat).loaded?
      account_stat.id = account_stat_id if account_stat.new_record?
      account_stat.reload
    end
  end

  def account_stat
    super || build_account_stat
  end

  private

  def save_account_stat
    return unless association(:account_stat).loaded? && account_stat&.changed?

    account_stat.save
  end
end
