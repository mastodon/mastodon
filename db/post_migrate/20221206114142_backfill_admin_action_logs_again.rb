# frozen_string_literal: true

class BackfillAdminActionLogsAgain < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  class Account < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    has_one :user, inverse_of: :account

    def local?
      domain.nil?
    end

    def acct
      local? ? username : "#{username}@#{domain}"
    end
  end

  class User < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account
  end

  class Status < ApplicationRecord
    include RoutingHelper

    # Dummy class, to make migration possible across version changes
    belongs_to :account

    def local?
      attributes['local'] || attributes['uri'].nil?
    end

    def uri
      local? ? activity_account_status_url(account, self) : attributes['uri']
    end
  end

  class DomainBlock < ApplicationRecord; end
  class DomainAllow < ApplicationRecord; end
  class EmailDomainBlock < ApplicationRecord; end
  class UnavailableDomain < ApplicationRecord; end

  class AccountWarning < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account
  end

  class Announcement < ApplicationRecord; end
  class IpBlock < ApplicationRecord; end
  class CustomEmoji < ApplicationRecord; end
  class CanonicalEmailBlock < ApplicationRecord; end

  class Appeal < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account
  end

  class AdminActionLog < ApplicationRecord
    # Dummy class, to make migration possible across version changes

    # Cannot use usual polymorphic support because of namespacing issues
    belongs_to :status, foreign_key: :target_id
    belongs_to :account, foreign_key: :target_id
    belongs_to :user
    belongs_to :domain_block, foreign_key: :target_id
    belongs_to :domain_allow, foreign_key: :target_id
    belongs_to :email_domain_block, foreign_key: :target_id
    belongs_to :unavailable_domain, foreign_key: :target_id
    belongs_to :account_warning, foreign_key: :target_id
    belongs_to :announcement, foreign_key: :target_id
    belongs_to :ip_block, foreign_key: :target_id
    belongs_to :custom_emoji, foreign_key: :target_id
    belongs_to :canonical_email_block, foreign_key: :target_id
    belongs_to :appeal, foreign_key: :target_id
  end

  def up
    safety_assured do
      process_logs_for_account
      process_logs_for_user
      process_logs_for_report
      process_logs_for_domain_block
      process_logs_for_domain_allow
      process_logs_for_email_domain_block
      process_logs_for_unavailable_domain
      process_logs_for_status
      process_logs_for_account_warning
      process_logs_for_announcement
      process_logs_for_ip_block
      process_logs_for_custom_emoji
      process_logs_for_canonical_email_block
      process_logs_for_appeal
    end
  end

  def down; end

  private

  def process_logs_for_account
    AdminActionLog.includes(:account).where(target_type: 'Account', human_identifier: nil).find_each do |log|
      next if log.account.nil?

      log.update_attribute('human_identifier', log.account.acct)
    end
  end

  def process_logs_for_user
    AdminActionLog.includes(user: :account).where(target_type: 'User', human_identifier: nil).find_each do |log|
      next if log.user.nil?

      log.update_attribute('human_identifier', log.user.account.acct)
      log.update_attribute('route_param', log.user.account_id)
    end
  end

  def process_logs_for_report
    AdminActionLog.where(target_type: 'Report', human_identifier: nil).in_batches.update_all('human_identifier = target_id::text')
  end

  def process_logs_for_domain_block
    AdminActionLog.includes(:domain_block).where(target_type: 'DomainBlock').find_each do |log|
      next if log.domain_block.nil?

      log.update_attribute('human_identifier', log.domain_block.domain)
    end
  end

  def process_logs_for_domain_allow
    AdminActionLog.includes(:domain_allow).where(target_type: 'DomainAllow').find_each do |log|
      next if log.domain_allow.nil?

      log.update_attribute('human_identifier', log.domain_allow.domain)
    end
  end

  def process_logs_for_email_domain_block
    AdminActionLog.includes(:email_domain_block).where(target_type: 'EmailDomainBlock').find_each do |log|
      next if log.email_domain_block.nil?

      log.update_attribute('human_identifier', log.email_domain_block.domain)
    end
  end

  def process_logs_for_unavailable_domain
    AdminActionLog.includes(:unavailable_domain).where(target_type: 'UnavailableDomain').find_each do |log|
      next if log.unavailable_domain.nil?

      log.update_attribute('human_identifier', log.unavailable_domain.domain)
    end
  end

  def process_logs_for_status
    AdminActionLog.includes(status: :account).where(target_type: 'Status', human_identifier: nil).find_each do |log|
      next if log.status.nil?

      log.update_attribute('human_identifier', log.status.account.acct)
      log.update_attribute('permalink', log.status.uri)
    end
  end

  def process_logs_for_account_warning
    AdminActionLog.includes(account_warning: :account).where(target_type: 'AccountWarning', human_identifier: nil).find_each do |log|
      next if log.account_warning.nil?

      log.update_attribute('human_identifier', log.account_warning.account.acct)
    end
  end

  def process_logs_for_announcement
    AdminActionLog.includes(:announcement).where(target_type: 'Announcement', human_identifier: nil).find_each do |log|
      next if log.announcement.nil?

      log.update_attribute('human_identifier', log.announcement.text)
    end
  end

  def process_logs_for_ip_block
    AdminActionLog.includes(:ip_block).where(target_type: 'IpBlock', human_identifier: nil).find_each do |log|
      next if log.ip_block.nil?

      log.update_attribute('human_identifier', "#{log.ip_block.ip}/#{log.ip_block.ip.prefix}")
    end
  end

  def process_logs_for_custom_emoji
    AdminActionLog.includes(:custom_emoji).where(target_type: 'CustomEmoji', human_identifier: nil).find_each do |log|
      next if log.custom_emoji.nil?

      log.update_attribute('human_identifier', log.custom_emoji.shortcode)
    end
  end

  def process_logs_for_canonical_email_block
    AdminActionLog.includes(:canonical_email_block).where(target_type: 'CanonicalEmailBlock', human_identifier: nil).find_each do |log|
      next if log.canonical_email_block.nil?

      log.update_attribute('human_identifier', log.canonical_email_block.canonical_email_hash)
    end
  end

  def process_logs_for_appeal
    AdminActionLog.includes(appeal: :account).where(target_type: 'Appeal', human_identifier: nil).find_each do |log|
      next if log.appeal.nil?

      log.update_attribute('human_identifier', log.appeal.account.acct)
      log.update_attribute('route_param', log.appeal.account_warning_id)
    end
  end
end
