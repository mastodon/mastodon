# frozen_string_literal: true
# == Schema Information
#
# Table name: polls
#
#  id              :bigint(8)        not null, primary key
#  account_id      :bigint(8)
#  status_id       :bigint(8)
#  expires_at      :datetime
#  options         :string           default([]), not null, is an Array
#  cached_tallies  :bigint(8)        default([]), not null, is an Array
#  multiple        :boolean          default(FALSE), not null
#  hide_totals     :boolean          default(FALSE), not null
#  votes_count     :bigint(8)        default(0), not null
#  last_fetched_at :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Poll < ApplicationRecord
  include Expireable

  belongs_to :account
  belongs_to :status

  has_many :votes, class_name: 'PollVote', inverse_of: :poll, dependent: :destroy

  validates :options, presence: true
  validates :expires_at, presence: true, if: :local?
  validates_with PollValidator, if: :local?

  scope :attached, -> { where.not(status_id: nil) }
  scope :unattached, -> { where(status_id: nil) }

  before_validation :prepare_options
  before_validation :prepare_votes_count

  after_initialize :prepare_cached_tallies

  after_commit :reset_parent_cache, on: :update

  def loaded_options
    options.map.with_index { |title, key| Option.new(self, key.to_s, title, cached_tallies[key]) }
  end

  def unloaded_options
    options.map.with_index { |title, key| Option.new(self, key.to_s, title, nil) }
  end

  def possibly_stale?
    remote? && last_fetched_before_expiration? && time_passed_since_last_fetch?
  end

  delegate :local?, to: :account

  def remote?
    !local?
  end

  class Option < ActiveModelSerializers::Model
    attributes :id, :title, :votes_count, :poll

    def initialize(poll, id, title, votes_count)
      @poll        = poll
      @id          = id
      @title       = title
      @votes_count = votes_count
    end
  end

  private

  def prepare_cached_tallies
    self.cached_tallies = options.map { 0 } if cached_tallies.empty?
  end

  def prepare_votes_count
    self.votes_count = cached_tallies.sum unless cached_tallies.empty?
  end

  def prepare_options
    self.options = options.map(&:strip).reject(&:blank?)
  end

  def reset_parent_cache
    return if status_id.nil?
    Rails.cache.delete("statuses/#{status_id}")
  end

  def last_fetched_before_expiration?
    last_fetched_at.nil? || expires_at.nil? || last_fetched_at < expires_at
  end

  def time_passed_since_last_fetch?
    last_fetched_at.nil? || last_fetched_at < 1.minute.ago
  end
end
