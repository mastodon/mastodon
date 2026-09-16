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
  belongs_to :account

  after_initialize :set_salt
  before_save :set_filter_data

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

      UpdateAccountReachWorker.perform_async(account_reach_filter_id)
    end
  end

  def add(*hosts)
    return if saturated

    next_filter_class = BLOOM_FILTER_SIZES.index { |size| size > filter.size }
    threshold = ((next_filter_class.nil? ? TARGET_SATURATION_FALSE_POSITIVE_RATE : TARGET_FALSE_POSITIVE_RATE)**(1.0 / filter.k)) * filter.m

    hosts.each do |host|
      filter.add("#{salt}:#{host}")
      next if filter.set_bits < threshold

      # We have reached the threshold after which false-positives are too frequent for us.
      # Either update the filter or mark it as saturated.
      if next_filter_class.present?
        replace_filter!(BLOOM_FILTER_TARGET_CAPACITIES[next_filter_class])

        next_filter_class = BLOOM_FILTER_SIZES.index { |size| size > filter.size }
        threshold = ((next_filter_class.nil? ? TARGET_SATURATION_FALSE_POSITIVE_RATE : TARGET_FALSE_POSITIVE_RATE)**(1.0 / filter.k)) * filter.m
      else
        update!(saturated: true, bloom_filter: nil)

        break
      end
    end
  end

  def include?(host)
    return true if saturated

    filter.include?("#{salt}:#{host}")
  end

  def filter_inboxes(inboxes)
    return inboxes if saturated? || destroyed?
    return [] if filter.empty?

    inboxes.filter do |url|
      include?(Addressable::URI.parse(url).normalized_host)
    rescue
      true
    end
  end

  # NOTE: There ought to be a better way of doing this…
  def reload
    super

    @filter = nil if defined?(@filter)

    self
  end

  private

  def filter
    @filter ||= begin
      if bloom_filter
        BloomFit.unpack(bloom_filter)
      else
        BloomFit.new(capacity: BLOOM_FILTER_TARGET_CAPACITIES.first, false_positive_rate: TARGET_FALSE_POSITIVE_RATE)
      end
    end
  end

  def replace_filter!(capacity)
    # TODO: is this a good idea? this will be expensive
    @filter = BloomFit.new(capacity:, false_positive_rate: TARGET_FALSE_POSITIVE_RATE).tap do |new_filter|
      Account.inboxes.each do |inbox|
        entry = "#{salt}:#{Addressable::URI.parse(inbox).normalized_host}"
        new_filter.add(entry) if @filter.include?(entry)
      end
    end
  end

  def set_salt
    self.salt ||= SecureRandom.alphanumeric(4)
  end

  def set_filter_data
    self.bloom_filter = saturated ? nil : @filter.to_msgpack if @filter
  end
end
