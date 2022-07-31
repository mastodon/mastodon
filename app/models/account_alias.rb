# frozen_string_literal: true

# == Schema Information
#
# Table name: account_aliases
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)
#  acct       :string           default(""), not null
#  uri        :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AccountAlias < ApplicationRecord
  belongs_to :account

  validates :acct, presence: true, domain: { acct: true }
  validates :uri, uniqueness: { scope: :account_id }
  validate :validate_target_account

  before_validation :set_uri
  after_create :add_to_account
  after_destroy :remove_from_account

  def acct=(val)
    val = val.to_s.strip
    super(val.start_with?('@') ? val[1..-1] : val)
  end

  def pretty_acct
    username, domain = acct.split('@')
    domain.nil? ? username : "#{username}@#{Addressable::IDNA.to_unicode(domain)}"
  end

  private

  def set_uri
    target_account = ResolveAccountService.new.call(acct)
    self.uri       = ActivityPub::TagManager.instance.uri_for(target_account) unless target_account.nil?
  rescue Webfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::Error
    # Validation will take care of it
  end

  def add_to_account
    account.update(also_known_as: account.also_known_as + [uri])
  end

  def remove_from_account
    account.update(also_known_as: account.also_known_as.reject { |x| x == uri })
  end

  def validate_target_account
    if uri.blank?
      errors.add(:acct, I18n.t('migrations.errors.not_found'))
    elsif ActivityPub::TagManager.instance.uri_for(account) == uri
      errors.add(:acct, I18n.t('migrations.errors.move_to_self'))
    end
  end
end
