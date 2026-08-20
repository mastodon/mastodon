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

  # Ideal false positive rate
  TARGET_FALSE_POSITIVE_RATE = 0.001

  # Tolerated false positive rate for largest-size bloom filters
  TARGET_SATURATION_FALSE_POSITIVE_RATE = 0.75

  # Largest allowed size for a bloom filter before upgrade
  BLOOM_SIZE_FILTER_THRESHOLD = 1.kilobyte * 8

  def add(*hosts)
    return if saturated

    threshold = ((filter.size < BLOOM_SIZE_FILTER_THRESHOLD ? TARGET_FALSE_POSITIVE_RATE : TARGET_SATURATION_FALSE_POSITIVE_RATE)**(1.0 / filter.k)) * filter.m

    hosts.each do |host|
      filter.add("#{salt}:#{host}")

      if filter.size < BLOOM_SIZE_FILTER_THRESHOLD
        upgrade_filter! if filter.set_bits >= threshold

        threshold = (TARGET_SATURATION_FALSE_POSITIVE_RATE**(1.0 / filter.k)) * filter.m
      elsif filter.set_bits >= threshold
        update!(saturated: true, bloom_filter: nil)

        break
      end
    end
  end

  def include?(host)
    return true if saturated

    filter.include?("#{salt}:#{host}")
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
        BloomFit.new(capacity: 300, false_positive_rate: TARGET_FALSE_POSITIVE_RATE)
      end
    end
  end

  def upgrade_filter!
    # TODO: is this a good idea? this will be expensive
    @filter = BloomFit.new(capacity: 10_000, false_positive_rate: TARGET_FALSE_POSITIVE_RATE).tap do |new_filter|
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
    self.bloom_filter = saturated ? nil : filter.to_msgpack
  end
end
