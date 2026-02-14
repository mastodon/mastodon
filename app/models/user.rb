# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                        :bigint(8)        not null, primary key
#  age_verified_at           :datetime
#  approved                  :boolean          default(TRUE), not null
#  chosen_languages          :string           is an Array
#  confirmation_sent_at      :datetime
#  confirmation_token        :string
#  confirmed_at              :datetime
#  consumed_timestep         :integer
#  current_sign_in_at        :datetime
#  disabled                  :boolean          default(FALSE), not null
#  email                     :string           default(""), not null
#  encrypted_password        :string           default(""), not null
#  last_emailed_at           :datetime
#  last_sign_in_at           :datetime
#  locale                    :string
#  otp_backup_codes          :string           is an Array
#  otp_required_for_login    :boolean          default(FALSE), not null
#  otp_secret                :string
#  require_tos_interstitial  :boolean          default(FALSE), not null
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  settings                  :text
#  sign_in_count             :integer          default(0), not null
#  sign_in_token             :string
#  sign_in_token_sent_at     :datetime
#  sign_up_ip                :inet
#  time_zone                 :string
#  unconfirmed_email         :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  account_id                :bigint(8)        not null
#  created_by_application_id :bigint(8)
#  invite_id                 :bigint(8)
#  role_id                   :bigint(8)
#  webauthn_id               :string
#

class User < ApplicationRecord
  self.ignored_columns += %w(
    admin
    current_sign_in_ip
    encrypted_otp_secret
    encrypted_otp_secret_iv
    encrypted_otp_secret_salt
    filtered_languages
    last_sign_in_ip
    moderator
    remember_created_at
    remember_token
    skip_sign_in_token
  )

  include LanguagesHelper
  include Redisable
  include User::Activity
  include User::Confirmation
  include User::HasSettings
  include User::LdapAuthenticable
  include User::Omniauthable
  include User::PamAuthenticable

  devise :two_factor_authenticatable,
         otp_secret_length: 32

  devise :two_factor_backupable,
         otp_number_of_backup_codes: 10

  devise :registerable, :recoverable, :validatable,
         :confirmable

  belongs_to :account, inverse_of: :user
  belongs_to :invite, counter_cache: :uses, optional: true
  belongs_to :created_by_application, class_name: 'Doorkeeper::Application', optional: true
  belongs_to :role, class_name: 'UserRole', optional: true
  accepts_nested_attributes_for :account

  has_many :applications, class_name: 'Doorkeeper::Application', as: :owner, dependent: nil
  has_many :backups, inverse_of: :user, dependent: nil
  has_many :invites, inverse_of: :user, dependent: nil
  has_many :login_activities, inverse_of: :user, dependent: :destroy
  has_many :markers, inverse_of: :user, dependent: :destroy
  has_many :webauthn_credentials, dependent: :destroy
  has_many :ips, class_name: 'UserIp', inverse_of: :user, dependent: nil

  has_one :invite_request, class_name: 'UserInviteRequest', inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :invite_request, reject_if: ->(attributes) { attributes['text'].blank? && !Setting.require_invite_text }
  validates :invite_request, presence: true, on: :create, if: :invite_text_required?

  validates :email, presence: true, email_address: true

  validates_with UserEmailValidator, if: -> { ENV['EMAIL_DOMAIN_LISTS_APPLY_AFTER_CONFIRMATION'] == 'true' || !confirmed? }
  validates_with EmailMxValidator, if: :validate_email_dns?
  validates :agreement, acceptance: { allow_nil: false, accept: [true, 'true', '1'] }, on: :create

  # Honeypot/anti-spam fields
  attr_accessor :registration_form_time, :website, :confirm_password

  validates_with RegistrationFormTimeValidator, on: :create
  validates :website, absence: true, on: :create
  validates :confirm_password, absence: true, on: :create
  validates :date_of_birth, presence: true, date_of_birth: true, on: :create, if: -> { Setting.min_age.present? && !bypass_registration_checks? }
  validate :validate_role_elevation

  scope :account_not_suspended, -> { joins(:account).merge(Account.without_suspended) }
  scope :recent, -> { order(id: :desc) }
  scope :pending, -> { where(approved: false) }
  scope :approved, -> { where(approved: true) }
  scope :enabled, -> { where(disabled: false) }
  scope :disabled, -> { where(disabled: true) }
  scope :active, -> { confirmed.signed_in_recently.account_not_suspended }
  scope :matches_email, ->(value) { where(arel_table[:email].matches("#{value}%")) }
  scope :matches_ip, ->(value) { left_joins(:ips).merge(IpBlock.contained_by(value)).group(users: [:id]) }

  before_validation :sanitize_role
  before_create :set_approved
  before_create :set_age_verified_at
  after_commit :send_pending_devise_notifications
  after_create_commit :trigger_webhooks

  normalizes :locale, with: ->(locale) { I18n.available_locales.exclude?(locale.to_sym) ? nil : locale }
  normalizes :time_zone, with: ->(time_zone) { ActiveSupport::TimeZone[time_zone].nil? ? nil : time_zone }
  normalizes :chosen_languages, with: ->(chosen_languages) { chosen_languages.compact_blank.presence }

  has_many :session_activations, dependent: :destroy

  delegate :can?, to: :role

  attr_reader :invite_code
  attr_writer :current_account

  attribute :external, :boolean, default: false
  attribute :bypass_registration_checks, :boolean, default: false
  attribute :date_of_birth, :date

  def self.those_who_can(*any_of_privileges)
    matching_role_ids = UserRole.that_can(*any_of_privileges).map(&:id)

    if matching_role_ids.empty?
      none
    else
      where(role_id: matching_role_ids)
    end
  end

  def self.skip_mx_check?
    Rails.env.local?
  end

  def role
    if role_id.nil?
      UserRole.everyone
    else
      super
    end
  end

  def invited?
    invite_id.present?
  end

  def valid_invitation?
    invite_id.present? && invite.valid_for_use?
  end

  def disable!
    update!(disabled: true)

    # This terminates all connections for the given account with the streaming
    # server:
    redis.publish("timeline:system:#{account.id}", Oj.dump(event: :kill))
  end

  def enable!
    update!(disabled: false)
  end

  def to_log_human_identifier
    account.acct
  end

  def to_log_route_param
    account_id
  end

  # Mark current email as confirmed, bypassing Devise
  def mark_email_as_confirmed!
    wrap_email_confirmation do
      skip_confirmation!
      save!
    end
  end

  def email_domain
    Mail::Address.new(email).domain
  rescue Mail::Field::ParseError
    nil
  end

  def update_sign_in!(new_sign_in: false)
    new_current = Time.now.utc
    self.last_sign_in_at     = current_sign_in_at || new_current
    self.current_sign_in_at  = new_current

    increment(:sign_in_count) if new_sign_in

    save(validate: false) unless new_record?
    prepare_returning_user!
  end

  def pending?
    !approved?
  end

  def active_for_authentication?
    !account.memorial?
  end

  def functional?
    functional_or_moved? && account.moved_to_account_id.nil?
  end

  def functional_or_moved?
    confirmed? && approved? && !disabled? && !account.unavailable? && !account.memorial? && !missing_2fa?
  end

  def missing_2fa?
    !two_factor_enabled? && role.require_2fa?
  end

  def unconfirmed_or_pending?
    unconfirmed? || pending?
  end

  def approve!
    return if approved?

    update!(approved: true)

    # Avoid extremely unlikely race condition when approving and confirming
    # the user at the same time
    reload unless confirmed?
    prepare_new_user! if confirmed?
  end

  def otp_enabled?
    otp_required_for_login
  end

  def webauthn_enabled?
    webauthn_credentials.any?
  end

  def two_factor_enabled?
    otp_required_for_login? || webauthn_credentials.any?
  end

  def disable_two_factor!
    self.otp_required_for_login = false
    self.otp_secret = nil
    otp_backup_codes&.clear

    webauthn_credentials.destroy_all if webauthn_enabled?

    save!
  end

  def applications_last_used
    Doorkeeper::AccessToken
      .where(resource_owner_id: id)
      .where.not(last_used_at: nil)
      .group(:application_id)
      .maximum(:last_used_at)
      .to_h
  end

  def token_for_app(app)
    return nil if app.nil? || app.owner != self

    Doorkeeper::AccessToken.find_or_create_by(application_id: app.id, resource_owner_id: id) do |t|
      t.scopes            = app.scopes
      t.expires_in        = Doorkeeper.configuration.access_token_expires_in
      t.use_refresh_token = Doorkeeper.configuration.refresh_token_enabled?
    end
  end

  def activate_session(request)
    session_activations.activate(
      session_id: SecureRandom.hex,
      user_agent: request.user_agent,
      ip: request.remote_ip
    ).session_id
  end

  def clear_other_sessions(id)
    session_activations.exclusive(id)
  end

  def web_push_subscription(session)
    session.web_push_subscription.nil? ? nil : session.web_push_subscription
  end

  def invite_code=(code)
    self.invite  = Invite.find_by(code: code) if code.present?
    @invite_code = code
  end

  def password_required?
    return false if external?

    super
  end

  def external_or_valid_password?(compare_password)
    # If encrypted_password is blank, we got the user from LDAP or PAM,
    # so credentials are already valid

    encrypted_password.blank? || valid_password?(compare_password)
  end

  def send_reset_password_instructions
    return false if encrypted_password.blank?

    super
  end

  def reset_password(new_password, new_password_confirmation)
    return false if encrypted_password.blank?

    super
  end

  def revoke_access!
    Doorkeeper::AccessGrant.by_resource_owner(self).touch_all(:revoked_at)

    Doorkeeper::AccessToken.by_resource_owner(self).in_batches do |batch|
      batch.touch_all(:revoked_at)
      Web::PushSubscription.where(access_token_id: batch).delete_all

      # Revoke each access token for the Streaming API, since `update_all``
      # doesn't trigger ActiveRecord Callbacks:
      # TODO: #28793 Combine into a single topic
      payload = Oj.dump(event: :kill)
      redis.pipelined do |pipeline|
        batch.ids.each do |id|
          pipeline.publish("timeline:access_token:#{id}", payload)
        end
      end
    end
  end

  def reset_password!
    # First, change password to something random, this revokes sessions and on-going access:
    change_password!(SecureRandom.hex)

    # Finally, send a reset password prompt to the user
    send_reset_password_instructions
  end

  def change_password!(new_password)
    # First, change password to something random and deactivate all sessions
    transaction do
      update(password: new_password)
      session_activations.destroy_all
    end

    # Then, remove all authorized applications and connected push subscriptions
    revoke_access!
  end

  protected

  def send_devise_notification(notification, *args, **kwargs)
    # This method can be called in `after_update` and `after_commit` hooks,
    # but we must make sure the mailer is actually called *after* commit,
    # otherwise it may work on stale data. To do this, figure out if we are
    # within a transaction.

    # It seems like devise sends keyword arguments as a hash in the last
    # positional argument
    kwargs = args.pop if args.last.is_a?(Hash) && kwargs.empty?

    if ActiveRecord::Base.connection.current_transaction.try(:records)&.include?(self)
      pending_devise_notifications << [notification, args, kwargs]
    else
      render_and_send_devise_message(notification, *args, **kwargs)
    end
  end

  private

  def send_pending_devise_notifications
    pending_devise_notifications.each do |notification, args, kwargs|
      render_and_send_devise_message(notification, *args, **kwargs)
    end

    # Empty the pending notifications array because the
    # after_commit hook can be called multiple times which
    # could cause multiple emails to be sent.
    pending_devise_notifications.clear
  end

  def pending_devise_notifications
    @pending_devise_notifications ||= []
  end

  def render_and_send_devise_message(notification, *, **)
    devise_mailer.send(notification, self, *, **).deliver_later
  end

  def set_approved
    self.approved = begin
      if requires_approval?
        false
      else
        open_registrations? || valid_invitation? || external?
      end
    end
  end

  def set_age_verified_at
    self.age_verified_at = Time.now.utc if Setting.min_age.present?
  end

  def grant_approval_on_confirmation?
    # Re-check approval on confirmation if the server has switched to open registrations
    open_registrations? && !requires_approval?
  end

  def requires_approval?
    sign_up_from_ip_requires_approval? || sign_up_email_requires_approval? || sign_up_username_requires_approval?
  end

  def wrap_email_confirmation
    new_user      = !confirmed?
    self.approved = true if grant_approval_on_confirmation?

    yield

    after_confirmation_tasks if new_user
  end

  def after_confirmation_tasks
    # Handle condition when approving and confirming a user at the same time
    reload unless approved?

    if approved?
      prepare_new_user!
    else
      notify_staff_about_pending_account!
    end
  end

  def sign_up_from_ip_requires_approval?
    sign_up_ip.present? && IpBlock.severity_sign_up_requires_approval.containing(sign_up_ip.to_s).exists?
  end

  def sign_up_email_requires_approval?
    return false if email.blank?

    _, domain = email.split('@', 2)
    return false if domain.blank?

    records = []

    # Doing this conditionally is not very satisfying, but this is consistent
    # with the MX records validations we do and keeps the specs tractable.
    records = DomainResource.new(domain).mx unless self.class.skip_mx_check?

    EmailDomainBlock.requires_approval?(records + [domain], attempt_ip: sign_up_ip)
  end

  def sign_up_username_requires_approval?
    account.username? && UsernameBlock.matches?(account.username, allow_with_approval: true)
  end

  def open_registrations?
    Setting.registrations_mode == 'open'
  end

  def sanitize_role
    self.role = nil if role.present? && role.everyone?
  end

  def prepare_new_user!
    BootstrapTimelineWorker.perform_async(account_id)
    ActivityTracker.increment('activity:accounts:local')
    ActivityTracker.record('activity:logins', id)
    UserMailer.welcome(self).deliver_later(wait: 1.hour)
    TriggerWebhookWorker.perform_async('account.approved', 'Account', account_id)
  end

  def prepare_returning_user!
    return unless confirmed?

    ActivityTracker.record('activity:logins', id)
    regenerate_feed! if inactive_since_duration?
  end

  def notify_staff_about_pending_account!
    User.those_who_can(:manage_users).includes(:account).find_each do |u|
      next unless u.allows_pending_account_emails?

      AdminMailer.with(recipient: u.account).new_pending_account(self).deliver_later
    end
  end

  def regenerate_feed!
    home_feed = HomeFeed.new(account)
    return if home_feed.regenerating?

    home_feed.regeneration_in_progress!
    RegenerationWorker.perform_async(account_id)
  end

  def validate_email_dns?
    email_changed? && !external? && !self.class.skip_mx_check?
  end

  def validate_role_elevation
    errors.add(:role_id, :elevated) if defined?(@current_account) && role&.overrides?(@current_account&.user_role)
  end

  def invite_text_required?
    Setting.require_invite_text && !open_registrations? && !invited? && !external? && !bypass_registration_checks?
  end

  def trigger_webhooks
    TriggerWebhookWorker.perform_async('account.created', 'Account', account_id)
  end
end
