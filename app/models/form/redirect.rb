# frozen_string_literal: true

class Form::Redirect
  include ActiveModel::Model

  attr_accessor :account, :target_account, :current_password,
                :current_username

  attr_reader :acct

  validates :acct, presence: true, domain: { acct: true }
  validate :validate_target_account

  def valid_with_challenge?(current_user)
    if current_user.encrypted_password.present?
      errors.add(:current_password, :invalid) unless current_user.valid_password?(current_password)
    else
      errors.add(:current_username, :invalid) unless account.username == current_username
    end

    return false unless errors.empty?

    set_target_account
    valid?
  end

  def acct=(val)
    @acct = val.to_s.strip.gsub(/\A@/, '')
  end

  private

  def set_target_account
    @target_account = ResolveAccountService.new.call(acct, skip_cache: true)
  rescue Webfinger::Error, *Mastodon::HTTP_CONNECTION_ERRORS, Mastodon::Error, Addressable::URI::InvalidURIError
    # Validation will take care of it
  end

  def validate_target_account
    if target_account.nil?
      errors.add(:acct, I18n.t('migrations.errors.not_found'))
    else
      errors.add(:acct, I18n.t('migrations.errors.already_moved')) if account.moved? && account.moved_to_account_id == target_account.id
      errors.add(:acct, I18n.t('migrations.errors.move_to_self')) if account.id == target_account.id
    end
  end
end
