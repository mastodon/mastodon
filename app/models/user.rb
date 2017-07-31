# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  email                     :string           default(""), not null
#  account_id                :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  encrypted_password        :string           default(""), not null
#  reset_password_token      :string
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0), not null
#  current_sign_in_at        :datetime
#  last_sign_in_at           :datetime
#  current_sign_in_ip        :inet
#  last_sign_in_ip           :inet
#  admin                     :boolean          default(FALSE), not null
#  confirmation_token        :string
#  confirmed_at              :datetime
#  confirmation_sent_at      :datetime
#  unconfirmed_email         :string
#  locale                    :string
#  encrypted_otp_secret      :string
#  encrypted_otp_secret_iv   :string
#  encrypted_otp_secret_salt :string
#  consumed_timestep         :integer
#  otp_required_for_login    :boolean          default(FALSE), not null
#  last_emailed_at           :datetime
#  otp_backup_codes          :string           is an Array
#  filtered_languages        :string           default([]), not null, is an Array
#

class User < ApplicationRecord
  include Settings::Extend
  ACTIVE_DURATION = 14.days

  devise :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :confirmable,
         :two_factor_authenticatable, :two_factor_backupable,
         otp_secret_encryption_key: ENV['OTP_SECRET'],
         otp_number_of_backup_codes: 10

  belongs_to :account, inverse_of: :user, required: true
  accepts_nested_attributes_for :account

  validates :locale, inclusion: I18n.available_locales.map(&:to_s), if: :locale?
  validates_with BlacklistedEmailValidator, if: :email_changed?

  scope :recent,    -> { order(id: :desc) }
  scope :admins,    -> { where(admin: true) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :inactive, -> { where(arel_table[:current_sign_in_at].lt(ACTIVE_DURATION.ago)) }
  scope :active, -> { confirmed.where(arel_table[:current_sign_in_at].gteq(ACTIVE_DURATION.ago)).joins(:account).where(accounts: { suspended: false }) }
  scope :matches_email, ->(value) { where(arel_table[:email].matches("#{value}%")) }
  scope :with_recent_ip_address, ->(value) { where(arel_table[:current_sign_in_ip].eq(value).or(arel_table[:last_sign_in_ip].eq(value))) }

  before_validation :sanitize_languages

  # This avoids a deprecation warning from Rails 5.1
  # It seems possible that a future release of devise-two-factor will
  # handle this itself, and this can be removed from our User class.
  attribute :otp_secret

  has_many :session_activations, dependent: :destroy

  def confirmed?
    confirmed_at.present?
  end

  def disable_two_factor!
    self.otp_required_for_login = false
    otp_backup_codes&.clear
    save!
  end

  def setting_default_privacy
    settings.default_privacy || (account.locked? ? 'private' : 'public')
  end

  def setting_default_sensitive
    settings.default_sensitive
  end

  def setting_unfollow_modal
    settings.unfollow_modal
  end

  def setting_boost_modal
    settings.boost_modal
  end

  def setting_delete_modal
    settings.delete_modal
  end

  def setting_auto_play_gif
    settings.auto_play_gif
  end

  def setting_system_font_ui
    settings.system_font_ui
  end

  def setting_noindex
    settings.noindex
  end

  def activate_session(request)
    session_activations.activate(session_id: SecureRandom.hex,
                                 user_agent: request.user_agent,
                                 ip: request.ip).session_id
  end

  def exclusive_session(id)
    session_activations.exclusive(id)
  end

  def session_active?(id)
    session_activations.active? id
  end

  def web_push_subscription(session)
    session.web_push_subscription.nil? ? nil : session.web_push_subscription.as_payload
  end

  protected

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

  def sanitize_languages
    filtered_languages.reject!(&:blank?)
  end
end
