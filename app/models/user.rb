# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id                        :bigint(8)        not null, primary key
#  email                     :string           default(""), not null
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
#  account_id                :bigint(8)        not null
#  disabled                  :boolean          default(FALSE), not null
#  moderator                 :boolean          default(FALSE), not null
#  invite_id                 :bigint(8)
#  remember_token            :string
#  chosen_languages          :string           is an Array
#  created_by_application_id :bigint(8)
#

class User < ApplicationRecord
  include Settings::Extend
  include Omniauthable

  # The home and list feeds will be stored in Redis for this amount
  # of time, and status fan-out to followers will include only people
  # within this time frame. Lowering the duration may improve performance
  # if lots of people sign up, but not a lot of them check their feed
  # every day. Raising the duration reduces the amount of expensive
  # RegenerationWorker jobs that need to be run when those people come
  # to check their feed
  ACTIVE_DURATION = ENV.fetch('USER_ACTIVE_DAYS', 7).to_i.days.freeze

  devise :two_factor_authenticatable,
         otp_secret_encryption_key: Rails.configuration.x.otp_secret

  devise :two_factor_backupable,
         otp_number_of_backup_codes: 10

  devise :registerable, :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  devise :pam_authenticatable if ENV['PAM_ENABLED'] == 'true'

  devise :omniauthable

  belongs_to :account, inverse_of: :user
  belongs_to :invite, counter_cache: :uses, optional: true
  belongs_to :created_by_application, class_name: 'Doorkeeper::Application', optional: true
  accepts_nested_attributes_for :account

  has_many :applications, class_name: 'Doorkeeper::Application', as: :owner
  has_many :backups, inverse_of: :user

  validates :locale, inclusion: I18n.available_locales.map(&:to_s), if: :locale?
  validates_with BlacklistedEmailValidator, if: :email_changed?
  validates_with EmailMxValidator, if: :validate_email_dns?
  validates :agreement, acceptance: { allow_nil: false, accept: [true, 'true', '1'] }, on: :create

  scope :recent, -> { order(id: :desc) }
  scope :admins, -> { where(admin: true) }
  scope :moderators, -> { where(moderator: true) }
  scope :staff, -> { admins.or(moderators) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :enabled, -> { where(disabled: false) }
  scope :inactive, -> { where(arel_table[:current_sign_in_at].lt(ACTIVE_DURATION.ago)) }
  scope :active, -> { confirmed.where(arel_table[:current_sign_in_at].gteq(ACTIVE_DURATION.ago)).joins(:account).where(accounts: { suspended: false }) }
  scope :matches_email, ->(value) { where(arel_table[:email].matches("#{value}%")) }
  scope :emailable, -> { confirmed.enabled.joins(:account).merge(Account.searchable) }

  before_validation :sanitize_languages

  # This avoids a deprecation warning from Rails 5.1
  # It seems possible that a future release of devise-two-factor will
  # handle this itself, and this can be removed from our User class.
  attribute :otp_secret

  has_many :session_activations, dependent: :destroy

  delegate :auto_play_gif, :default_sensitive, :unfollow_modal, :boost_modal, :delete_modal,
           :reduce_motion, :system_font_ui, :noindex, :theme, :display_media, :hide_network,
           :expand_spoilers, :default_language, :aggregate_reblogs, to: :settings, prefix: :setting, allow_nil: false

  attr_reader :invite_code

  def pam_conflict(_)
    # block pam login tries on traditional account
    nil
  end

  def pam_conflict?
    return false unless Devise.pam_authentication
    encrypted_password.present? && pam_managed_user?
  end

  def pam_get_name
    return account.username if account.present?
    super
  end

  def pam_setup(_attributes)
    acc = Account.new(username: pam_get_name)
    acc.save!(validate: false)

    self.email = "#{acc.username}@#{find_pam_suffix}" if email.nil? && find_pam_suffix
    self.confirmed_at = Time.now.utc
    self.admin = false
    self.account = acc

    acc.destroy! unless save
  end

  def ldap_setup(_attributes)
    self.confirmed_at = Time.now.utc
    self.admin = false
    save!
  end

  def confirmed?
    confirmed_at.present?
  end

  def invited?
    invite_id.present?
  end

  def staff?
    admin? || moderator?
  end

  def role
    if admin?
      'admin'
    elsif moderator?
      'moderator'
    else
      'user'
    end
  end

  def role?(role)
    case role
    when 'user'
      true
    when 'moderator'
      staff?
    when 'admin'
      admin?
    else
      false
    end
  end

  def disable!
    update!(disabled: true,
            last_sign_in_at: current_sign_in_at,
            current_sign_in_at: nil)
  end

  def enable!
    update!(disabled: false)
  end

  def confirm
    new_user = !confirmed?

    super
    prepare_new_user! if new_user
  end

  def confirm!
    new_user = !confirmed?

    skip_confirmation!
    save!
    prepare_new_user! if new_user
  end

  def update_tracked_fields!(request)
    super
    prepare_returning_user!
  end

  def promote!
    if moderator?
      update!(moderator: false, admin: true)
    elsif !admin?
      update!(moderator: true)
    end
  end

  def demote!
    if admin?
      update!(admin: false, moderator: true)
    elsif moderator?
      update!(moderator: false)
    end
  end

  def disable_two_factor!
    self.otp_required_for_login = false
    otp_backup_codes&.clear
    save!
  end

  def setting_default_privacy
    settings.default_privacy || (account.locked? ? 'private' : 'public')
  end

  def allows_digest_emails?
    settings.notification_emails['digest']
  end

  def allows_report_emails?
    settings.notification_emails['report']
  end

  def hides_network?
    @hides_network ||= settings.hide_network
  end

  def aggregates_reblogs?
    @aggregates_reblogs ||= settings.aggregate_reblogs
  end

  def token_for_app(a)
    return nil if a.nil? || a.owner != self
    Doorkeeper::AccessToken
      .find_or_create_by(application_id: a.id, resource_owner_id: id) do |t|

      t.scopes = a.scopes
      t.expires_in = Doorkeeper.configuration.access_token_expires_in
      t.use_refresh_token = Doorkeeper.configuration.refresh_token_enabled?
    end
  end

  def activate_session(request)
    session_activations.activate(session_id: SecureRandom.hex,
                                 user_agent: request.user_agent,
                                 ip: request.remote_ip).session_id
  end

  def exclusive_session(id)
    session_activations.exclusive(id)
  end

  def session_active?(id)
    session_activations.active? id
  end

  def web_push_subscription(session)
    session.web_push_subscription.nil? ? nil : session.web_push_subscription
  end

  def invite_code=(code)
    self.invite  = Invite.find_by(code: code) if code.present?
    @invite_code = code
  end

  def password_required?
    return false if Devise.pam_authentication || Devise.ldap_authentication
    super
  end

  def send_reset_password_instructions
    return false if encrypted_password.blank? && (Devise.pam_authentication || Devise.ldap_authentication)
    super
  end

  def reset_password!(new_password, new_password_confirmation)
    return false if encrypted_password.blank? && (Devise.pam_authentication || Devise.ldap_authentication)
    super
  end

  def self.pam_get_user(attributes = {})
    return nil unless attributes[:email]
    resource =
      if Devise.check_at_sign && !attributes[:email].index('@')
        joins(:account).find_by(accounts: { username: attributes[:email] })
      else
        find_by(email: attributes[:email])
      end

    if resource.blank?
      resource = new(email: attributes[:email], agreement: true)
      if Devise.check_at_sign && !resource[:email].index('@')
        resource[:email] = Rpam2.getenv(resource.find_pam_service, attributes[:email], attributes[:password], 'email', false)
        resource[:email] = "#{attributes[:email]}@#{resource.find_pam_suffix}" unless resource[:email]
      end
    end
    resource
  end

  def self.ldap_get_user(attributes = {})
    resource = joins(:account).find_by(accounts: { username: attributes[Devise.ldap_uid.to_sym].first })

    if resource.blank?
      resource = new(email: attributes[:mail].first, agreement: true, account_attributes: { username: attributes[Devise.ldap_uid.to_sym].first })
      resource.ldap_setup(attributes)
    end

    resource
  end

  def self.authenticate_with_pam(attributes = {})
    return nil unless Devise.pam_authentication
    super
  end

  def show_all_media?
    setting_display_media == 'show_all'
  end

  def hide_all_media?
    setting_display_media == 'hide_all'
  end

  protected

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

  def sanitize_languages
    return if chosen_languages.nil?
    chosen_languages.reject!(&:blank?)
    self.chosen_languages = nil if chosen_languages.empty?
  end

  def prepare_new_user!
    BootstrapTimelineWorker.perform_async(account_id)
    ActivityTracker.increment('activity:accounts:local')
    UserMailer.welcome(self).deliver_later
  end

  def prepare_returning_user!
    ActivityTracker.record('activity:logins', id)
    regenerate_feed! if needs_feed_update?
  end

  def regenerate_feed!
    return unless Redis.current.setnx("account:#{account_id}:regeneration", true)
    Redis.current.expire("account:#{account_id}:regeneration", 1.day.seconds)
    RegenerationWorker.perform_async(account_id)
  end

  def needs_feed_update?
    last_sign_in_at < ACTIVE_DURATION.ago
  end

  def validate_email_dns?
    email_changed? && !(Rails.env.test? || Rails.env.development?)
  end
end
