# frozen_string_literal: true

# == Schema Information
#
# Table name: email_subscriptions
#
#  id                 :bigint(8)        not null, primary key
#  confirmation_token :string
#  confirmed_at       :datetime
#  email              :string           not null
#  locale             :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint(8)        not null
#

class EmailSubscription < ApplicationRecord
  belongs_to :account

  normalizes :email, with: ->(str) { str.squish.downcase }

  validates :email, presence: true, email_address: true, length: { maximum: 320 }, uniqueness: { scope: :account_id }
  validates :email, email_mx: true, if: -> { email_changed? && !Rails.env.local? }

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  before_create :set_confirmation_token

  after_create_commit :send_confirmation_email

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    touch(:confirmed_at)
  end

  private

  def set_confirmation_token
    self.confirmation_token = Devise.friendly_token unless confirmed?
  end

  def send_confirmation_email
    EmailSubscriptionMailer.with(subscription: self).confirmation.deliver_later
  end
end
