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
  # filter and replace (“upgrade”) it with a larger one if needed, until the account has federated so much
  # that we consider the reach filter “saturated”, meaning the underlying bloom filter is not worth
  # keeping.
  #
  # Replacing a bloom filter is a costly operation, as we need to go through the set of possible values
  # and re-insert them in the new filter. Furthermore, false positives accumulate, so bloom filter
  # sizes must be chosen carefully and upgrades should be kept to a minimum.
  #
  # For instance, with a false positive of 0.001, on a server that knows about 100_000 different domains,
  # each filter upgrade may take a couple seconds to run and add around 100 false positives to the new filter.

  # Ideal false positive rate
  TARGET_FALSE_POSITIVE_RATE = 0.001

  # Tolerated false positive rate for largest-size bloom filters, after which a filter is considered saturated
  TARGET_SATURATION_FALSE_POSITIVE_RATE = 0.75

  # Target capacity for bloom filters of individual sizes
  BLOOM_FILTER_TARGET_CAPACITIES = [300, 10_000].freeze

  # Size of bloom filter for every target capacity, precomputed using BloomFilt's formula
  BLOOM_FILTER_SIZES = begin
    factor = -Math.log(TARGET_FALSE_POSITIVE_RATE) / (Math.log(2.0)**2)

    BLOOM_FILTER_TARGET_CAPACITIES.map { |capacity| (capacity * factor).ceil }
  end.freeze

  # Batch size for processing queued additions
  BATCH_SIZE = 500
  DEBOUNCE_DELAY = 5.minutes

  class BloomFilterSerializer
    def self.load(value)
      return BloomFit.new(capacity: BLOOM_FILTER_TARGET_CAPACITIES.first, false_positive_rate: TARGET_FALSE_POSITIVE_RATE) if value.nil?

      BloomFit.unpack(value)
    end

    def self.dump(value)
      return nil if value.empty?

      value.to_msgpack
    end
  end

  serialize :bloom_filter, coder: BloomFilterSerializer

  class << self
    include Redisable
    include AuthorizedFetchHelper

    # This is a class method rather than an instance method because we want to avoid
    # loading the database row: the `bloom_filter` column can be quite large
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
    return if saturated

    next_filter_class = BLOOM_FILTER_SIZES.index { |size| size > bloom_filter.size }
    threshold = ((next_filter_class.nil? ? TARGET_SATURATION_FALSE_POSITIVE_RATE : TARGET_FALSE_POSITIVE_RATE)**(1.0 / bloom_filter.k)) * bloom_filter.m

    hosts.each do |host|
      bloom_filter.add("#{salt}:#{host}")
      next if bloom_filter.set_bits < threshold

      # We have reached the threshold after which false-positives are too frequent for us.
      # Either update the filter or mark it as saturated.
      if next_filter_class.present?
        replace_filter!(BLOOM_FILTER_TARGET_CAPACITIES[next_filter_class])

        next_filter_class = BLOOM_FILTER_SIZES.index { |size| size > bloom_filter.size }
        threshold = ((next_filter_class.nil? ? TARGET_SATURATION_FALSE_POSITIVE_RATE : TARGET_FALSE_POSITIVE_RATE)**(1.0 / bloom_filter.k)) * bloom_filter.m
      else
        update!(saturated: true, bloom_filter: nil)

        break
      end
    end
  end

  def include?(host)
    return true if saturated

    bloom_filter.include?("#{salt}:#{host}")
  end

  def filter_inboxes(inboxes)
    return inboxes if destroyed? || saturated?

    process_queued_additions_with_lock!

    return inboxes if saturated?
    return [] if bloom_filter.blank?

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

  def replace_filter!(capacity)
    # TODO: is this a good idea? this will be expensive
    self.bloom_filter = BloomFit.new(capacity:, false_positive_rate: TARGET_FALSE_POSITIVE_RATE).tap do |new_filter|
      Account.inboxes.each do |inbox|
        entry = "#{salt}:#{Addressable::URI.parse(inbox).normalized_host}"
        new_filter.add(entry) if bloom_filter.include?(entry)
      end
    end
  end

  def set_salt
    self.salt ||= SecureRandom.alphanumeric(4)
  end
end
