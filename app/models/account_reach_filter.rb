# frozen_string_literal: true

# == Schema Information
#
# Table name: account_reach_filters
#
#  id           :bigint(8)        not null, primary key
#  account_id   :bigint(8)        not null
#  salt         :string           not null
#  bloom_filter :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class AccountReachFilter < ApplicationRecord
  belongs_to :account

  after_initialize :set_salt
  before_save :set_filter_data

  def add(host)
    # This is *not* a Rails method, but a BloomFilter one
    filter.insert("#{salt}:#{host}") # rubocop:disable Rails/SkipsModelValidations
  end

  def include?(host)
    filter.include?("#{salt}:#{host}")
  end

  # NOTE: There ought to be a better way of doing this…
  def reload
    super
    @filter.binary = bloom_filter if defined?(@filter)
    self
  end

  private

  def filter
    return @filter if defined?(@filter)

    # NOTE: the filter's parameters cannot be changed
    @filter = BloomFilter.new(size: 10_000, error_rate: 0.1)
    @filter.binary = bloom_filter unless bloom_filter.nil?
    @filter
  end

  def set_salt
    self.salt ||= SecureRandom.alphanumeric(4)
  end

  def set_filter_data
    self.bloom_filter = filter.binary
  end
end
