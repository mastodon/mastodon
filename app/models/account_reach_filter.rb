# frozen_string_literal: true

# == Schema Information
#
# Table name: account_reach_filters
#
#  id           :bigint(8)        not null, primary key
#  bloom_filter :binary
#  salt         :string           not null
#  saturated    :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint(8)        not null
#
class AccountReachFilter < ApplicationRecord
  include Redisable
  include Lockable

  belongs_to :account

  after_initialize :set_salt

  # This class uses bloom filters to (optionally) keep track of which server is aware of an account.
  # Once an account with an `AccountReachFilter` has federated at least once, `bloom_filter` will
  # hold a bloom filter used to approximate the set of remote domains it has federated to.
  #
  # Before different accounts have widely different federation patterns, we start with a small bloom
  # filter and add new larger ones if needed, until the account has federated so much that we consider
  # the reach filter “saturated”, meaning the underlying bloom filter is not worth keeping.
  #
  # We use the same target positive rate for all individual bloom filters, so the more bloom filters
  # an account reach filter has, the more the total error rate will increase.
  #
  # For instance, with a false positive of 0.01%, on a server that knows about 100_000 different domains,
  # an account reach filter with 5 underlying bloom filters will cause around 50 false positives.

  # Ideal false positive rate
  TARGET_FALSE_POSITIVE_RATE = 0.001

  # Tolerated false positive rate for largest-size bloom filters, after which a filter is considered saturated
  TARGET_SATURATION_FALSE_POSITIVE_RATE = 0.75

  # Target capacity for bloom filters of individual sizes
  BLOOM_FILTER_TARGET_CAPACITIES = [300, 10_000].freeze

  # Batch size for processing queued additions
  BATCH_SIZE = 500
  DEBOUNCE_DELAY = 5.minutes

  class BloomFilterSerializer
    def self.load(value)
      return [] if value.nil?

      value = MessagePack.unpack(value)

      # A previous version of the code stored a single bloom filter
      value = [value] unless value.first.is_a?(Array)

      value.map do |marshal|
        BloomFit.allocate.tap { |bf| bf.marshal_load(marshal) }
      end
    end

    def self.dump(value)
      return nil if value.empty?

      MessagePack.pack(value.map(&:marshal_dump))
    end
  end

  # An earlier version used the name `bloom_filter`, but it can hold multiple
  alias_attribute :bloom_filters, :bloom_filter
  serialize :bloom_filters, coder: BloomFilterSerializer

  class << self
    include Redisable
    include AuthorizedFetchHelper

    # This is a class method rather than an instance method because we want to avoid
    # loading the database row: the `bloom_filters` column can be quite large
    def record_reach_for(account_id, inbox_url)
      # Remove reach filter if the we can't ensure we're going to handle every request
      return AccountReachFilter.where(account_id: account_id).delete_all unless actors_require_signature?

      # It's not ideal, but we have no way to tell the remote account about it…
      return if inbox_url.blank?

      account_reach_filter_id = AccountReachFilter.where(account_id: account_id, saturated: false).pick(:id)
      return if account_reach_filter_id.nil?

      with_redis do |redis|
        redis.sadd("account_reach:#{account_reach_filter_id}:to_add", Addressable::URI.parse(inbox_url).normalized_host)
      end

      UpdateAccountReachWorker.perform_in(DEBOUNCE_DELAY, account_reach_filter_id)
    end
  end

  def add(*hosts)
    return if saturated || hosts.empty?

    bloom_filters << BloomFit.new(capacity: BLOOM_FILTER_TARGET_CAPACITIES.first, false_positive_rate: TARGET_FALSE_POSITIVE_RATE) if bloom_filters.empty?

    next_filter_class = bloom_filters.size
    threshold = ((next_filter_class.nil? ? TARGET_SATURATION_FALSE_POSITIVE_RATE : TARGET_FALSE_POSITIVE_RATE)**(1.0 / bloom_filters.last.k)) * bloom_filters.last.m

    hosts.each do |host|
      next if include?(host)

      bloom_filters.last.add("#{salt}:#{host}")
      next if bloom_filters.last.set_bits < threshold

      # We have reached the threshold after which false-positives are too frequent for us.
      # Either update the filter or mark it as saturated.
      if next_filter_class < BLOOM_FILTER_TARGET_CAPACITIES.size
        bloom_filters << BloomFit.new(capacity: BLOOM_FILTER_TARGET_CAPACITIES[next_filter_class], false_positive_rate: TARGET_FALSE_POSITIVE_RATE)

        next_filter_class = bloom_filter.size
        threshold = ((next_filter_class.nil? ? TARGET_SATURATION_FALSE_POSITIVE_RATE : TARGET_FALSE_POSITIVE_RATE)**(1.0 / bloom_filters.last.k)) * bloom_filters.last.m
      else
        update!(saturated: true, bloom_filter: nil)

        break
      end
    end
  end

  def include?(host)
    return true if saturated

    bloom_filters.any? { |filter| filter.include?("#{salt}:#{host}") }
  end

  def filter_inboxes(inboxes)
    return inboxes if destroyed? || saturated?

    process_queued_additions_with_lock!

    return inboxes if saturated?
    return [] if bloom_filters.all?(&:blank?)

    inboxes.filter do |url|
      include?(Addressable::URI.parse(url).normalized_host)
    rescue
      true
    end
  end

  def process_queued_additions!
    with_redis do |redis|
      reload
      loop do
        domains = redis.spop("account_reach:#{id}:to_add", BATCH_SIZE)
        break if domains.blank?

        add(*domains)
      end
    end

    save!
  end

  private

  def process_queued_additions_with_lock!
    return unless persisted?
    raise 'AccountReachFilter changes need to be performed with a lock' if changed?

    with_redis_lock("consolidate_account_reach_filter:#{id}", autorelease: 5.minutes) do
      reload

      process_queued_additions!
    end
  end

  def set_salt
    self.salt ||= SecureRandom.alphanumeric(4)
  end
end
