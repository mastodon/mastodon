# frozen_string_literal: true

class Scheduler::VacuumScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    vacuum_operations.each do |operation|
      operation.perform
    rescue => e
      Rails.logger.error("Error while running #{operation.class.name}: #{e}")
    end
  end

  private

  def vacuum_operations
    [
      statuses_vacuum,
      media_attachments_vacuum,
      preview_cards_vacuum,
      backups_vacuum,
      access_tokens_vacuum,
      applications_vacuum,
      feeds_vacuum,
      imports_vacuum,
    ]
  end

  def statuses_vacuum
    Vacuum::StatusesVacuum.new(content_retention_policy.content_cache_retention_period)
  end

  def media_attachments_vacuum
    Vacuum::MediaAttachmentsVacuum.new(content_retention_policy.media_cache_retention_period)
  end

  def preview_cards_vacuum
    Vacuum::PreviewCardsVacuum.new(content_retention_policy.media_cache_retention_period)
  end

  def backups_vacuum
    Vacuum::BackupsVacuum.new(content_retention_policy.backups_retention_period)
  end

  def access_tokens_vacuum
    Vacuum::AccessTokensVacuum.new
  end

  def feeds_vacuum
    Vacuum::FeedsVacuum.new
  end

  def imports_vacuum
    Vacuum::ImportsVacuum.new
  end

  def applications_vacuum
    Vacuum::ApplicationsVacuum.new
  end

  def content_retention_policy
    ContentRetentionPolicy.current
  end
end
