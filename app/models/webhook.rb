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
    account.approved
    account.created
    report.created
  ).freeze

  attr_writer :current_account

  scope :enabled, -> { where(enabled: true) }

  validates :url, presence: true, url: true
  validates :secret, presence: true, length: { minimum: 12 }
  validates :events, presence: true

  validate :validate_events
  validate :validate_permissions

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

  def required_permissions
    events.map { |event| Webhook.permission_for_event(event) }
  end

  def self.permission_for_event(event)
    case event
    when 'account.approved', 'account.created', 'account.updated'
      :manage_users
    when 'report.created'
      :manage_reports
    end
  end

  private

  def validate_events
    errors.add(:events, :invalid) if events.any? { |e| !EVENTS.include?(e) }
  end

  def validate_permissions
    errors.add(:events, :invalid_permissions) if defined?(@current_account) && required_permissions.any? { |permission| !@current_account.user_role.can?(permission) }
  end

  def strip_events
    self.events = events.map { |str| str.strip.presence }.compact if events.present?
  end

  def generate_secret
    self.secret = SecureRandom.hex(20) if secret.blank?
  end
end
