# frozen_string_literal: true

# == Schema Information
#
# Table name: account_reach_filters
#
#  id           :bigint(8)        not null, primary key
#  bloom_filter :binary
#  salt         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint(8)        not null
#
class AccountReachFilter < ApplicationRecord
  belongs_to :account

  after_initialize :set_salt
  before_save :set_filter_data

  def add(host)
    filter.add("#{salt}:#{host}")
  end

  def include?(host)
    filter.include?("#{salt}:#{host}")
  end

  # NOTE: There ought to be a better way of doing this…
  def reload
    super

    @filter = BloomFit.unpack(bloom_filter) if defined?(@filter)

    self
  end

  private

  def filter
    @filter ||= begin
      if bloom_filter
        BloomFit.unpack(bloom_filter)
      else
        BloomFit.new(capacity: 10_000, false_positive_rate: 0.001)
      end
    end
  end

  def set_salt
    self.salt ||= SecureRandom.alphanumeric(4)
  end

  def set_filter_data
    self.bloom_filter = filter.to_msgpack
  end
end
