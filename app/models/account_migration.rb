# frozen_string_literal: true

# == Schema Information
#
# Table name: account_migrations
#
#  id                :bigint(8)        not null, primary key
#  account_id        :bigint(8)
#  acct              :string           default(""), not null
#  followers_count   :bigint(8)        default(0), not null
#  target_account_id :bigint(8)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class AccountMigration < ApplicationRecord
  include Redisable
  include Lockable

  COOLDOWN_PERIOD = 30.days.freeze

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  before_validation :set_target_account
  before_validation :set_followers_count

  validates :acct, presence: true, domain: { acct: true }
  validate :validate_migration_cooldown
  validate :validate_target_account

  scope :within_cooldown, ->(now = Time.now.utc) { where(arel_table[:created_at].gteq(now - COOLDOWN_PERIOD)) }

  attr_accessor :current_password, :current_username

  def save_with_challenge(current_user)
    if current_user.encrypted_password.present?
      errors.add(:current_password, :invalid) unless current_user.valid_password?(current_password)
    else
      errors.add(:current_username, :invalid) unless account.username == current_username
    end

    return false unless errors.empty?

    with_redis_lock("account_migration:#{account.id}") do
      save
    end
  end

  def cooldown_at
    created_at + COOLDOWN_PERIOD
  end

  def acct=(val)
    super(val.to_s.strip.gsub(/\A@/, ''))
  end

  private

  def set_target_account
    self.target_account = ResolveAccountService.new.call(acct, skip_cache: true)
  rescue Webfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::Error, Addressable::URI::InvalidURIError
    # Validation will take care of it
  end

  def set_followers_count
    self.followers_count = account.followers_count
  end

  def validate_target_account
    if target_account.nil?
      errors.add(:acct, I18n.t('migrations.errors.not_found'))
    else
      errors.add(:acct, I18n.t('migrations.errors.missing_also_known_as')) unless target_account.also_known_as.include?(ActivityPub::TagManager.instance.uri_for(account))
      errors.add(:acct, I18n.t('migrations.errors.already_moved')) if account.moved_to_account_id.present? && account.moved_to_account_id == target_account.id
      errors.add(:acct, I18n.t('migrations.errors.move_to_self')) if account.id == target_account.id
    end
  end

  def validate_migration_cooldown
    errors.add(:base, I18n.t('migrations.errors.on_cooldown')) if account.migrations.within_cooldown.exists?
  end
end
