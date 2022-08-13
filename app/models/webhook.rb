# frozen_string_literal: true

# == Schema Information
#
# Table name: webhooks
#
#  id         :bigint(8)        not null, primary key
#  url        :string           not null
#  events     :string           default([]), not null, is an Array
#  secret     :string           default(""), not null
#  enabled    :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Webhook < ApplicationRecord
  EVENTS = %w(
    account.created
    report.created
  ).freeze

  scope :enabled, -> { where(enabled: true) }

  validates :url, presence: true, url: true
  validates :secret, presence: true, length: { minimum: 12 }
  validates :events, presence: true

  validate :validate_events

  before_validation :strip_events
  before_validation :generate_secret

  def rotate_secret!
    update!(secret: SecureRandom.hex(20))
  end

  def enable!
    update!(enabled: true)
  end

  def disable!
    update!(enabled: false)
  end

  private

  def validate_events
    errors.add(:events, :invalid) if events.any? { |e| !EVENTS.include?(e) }
  end

  def strip_events
    self.events = events.map { |str| str.strip.presence }.compact if events.present?
  end

  def generate_secret
    self.secret = SecureRandom.hex(20) if secret.blank?
  end
end
