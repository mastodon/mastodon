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

    result = updated_account_stat(key, value.to_i)

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

  def updated_account_stat(key, value)
    AccountStat.upsert(
      initial_values(key, value),
      on_duplicate: Arel.sql(
        duplicate_values(key, value).join(', ')
      ),
      unique_by: :account_id
    )
  end

  def initial_values(key, value)
    { :account_id => id, key => [value, 0].max }.tap do |values|
      values.merge!(last_status_at: Time.current) if key == :statuses_count
    end
  end

  def duplicate_values(key, value)
    ["#{key} = (account_stats.#{key} + #{value})", 'updated_at = CURRENT_TIMESTAMP'].tap do |values|
      values << 'last_status_at = CURRENT_TIMESTAMP' if key == :statuses_count && value.positive?
    end
  end

  def save_account_stat
    return unless association(:account_stat).loaded? && account_stat&.changed?

    account_stat.save
  end
end
