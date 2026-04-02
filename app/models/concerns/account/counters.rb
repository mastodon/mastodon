# frozen_string_literal: true

module Account::Counters
  extend ActiveSupport::Concern

  ALLOWED_COUNTER_KEYS = %i(statuses_count following_count followers_count).freeze

  included do
    has_one :account_stat, inverse_of: :account, dependent: nil
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
  def increment_count!(key, status_created_at: nil)
    update_count!(key, 1, status_created_at:)
  end

  # @param [Symbol] key
  def decrement_count!(key)
    update_count!(key, -1)
  end

  # @param [Symbol] key
  # @param [Integer] value
  def update_count!(key, value, status_created_at: nil)
    raise ArgumentError, "Invalid key #{key}" unless ALLOWED_COUNTER_KEYS.include?(key)
    raise ArgumentError, 'Do not call update_count! on dirty objects' if association(:account_stat).loaded? && account_stat&.changed? && account_stat.changed_attribute_names_to_save == %w(id)

    result = updated_account_stat(key, value.to_i, status_created_at:)

    # Reload account_stat if it was loaded, taking into account newly-created unsaved records
    if association(:account_stat).loaded?
      account_stat.id = result.first['id'] if account_stat.new_record?
      account_stat.reload
    end
  end

  def account_stat
    super || build_account_stat
  end

  private

  def updated_account_stat(key, value, status_created_at: nil)
    status_created_at = Time.now.utc if status_created_at.nil? || status_created_at > Time.now.utc

    AccountStat.upsert(
      initial_values(key, value, status_created_at:),
      on_duplicate: Arel.sql(
        duplicate_values(key, value, status_created_at:).join(', ')
      ),
      unique_by: :account_id
    )
  end

  def initial_values(key, value, status_created_at: nil)
    { :account_id => id, key => [value, 0].max }.tap do |values|
      values.merge!(last_status_at: status_created_at) if key == :statuses_count
    end
  end

  def duplicate_values(key, value, status_created_at: nil)
    ["#{key} = (account_stats.#{key} + #{value})", 'updated_at = CURRENT_TIMESTAMP'].tap do |values|
      values << AccountStat.sanitize_sql_array(['last_status_at = GREATEST(account_stats.last_status_at, ?::timestamp)', status_created_at]) if key == :statuses_count && value.positive?
    end
  end

  def save_account_stat
    return unless association(:account_stat).loaded? && account_stat&.changed?

    account_stat.save
  end
end
