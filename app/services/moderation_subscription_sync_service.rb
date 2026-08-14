# frozen_string_literal: true

class ModerationSubscriptionSyncService < BaseService
  def call(subscription)
    case subscription.type
    when 'csv_list'
      synchronize_csv_moderation_subscription!(subscription)
    end
  end

  private

  def synchronize_csv_moderation_subscription!(subscription)
    Request.new(:get, subscription.url).add_headers('Accept' => 'text/csv').perform do |res|
      return false unless res.code == 200

      body = res.body_with_limit

      # TODO: find a way to deduplicate with `Admin::Import`
      csv_converter = lambda do |field, field_info|
        case field_info.header
        when '#domain'
          field&.downcase&.strip
        when '#public_comment'
          field&.strip
        when '#severity'
          field&.downcase&.strip&.to_sym
        when '#reject_media', '#reject_reports', '#obfuscate'
          ActiveModel::Type::Boolean.new.cast(field&.downcase)
        else
          field
        end
      end

      csv_data = CSV.new(body, encoding: 'UTF-8', skip_blanks: true, headers: true, converters: csv_converter)
      csv_data.take(1) # Ensure the headers are read
      csv_data = CSV.new(body, encoding: 'UTF-8', skip_blanks: true, headers: ['#domain'], converters: csv_converter) unless csv_data.headers&.first == '#domain'

      csv_data.rewind
      rows = csv_data.take(Admin::Import::ROWS_PROCESSING_LIMIT + 1)

      SubscribedAdvisory.upsert_all(
        rows.map do |row|
          {
            target_key: TagManager.instance.normalize_domain(row['#domain']),
            target_type: :domain,
            moderation_subscription_id: subscription.id,
            action: action_from_severity(subscription, row),
          }
        end,
        unique_by: [:target_type, :target_key, :moderation_subscription_id]
      )

      subscription.advisories.domain_target_type.where.not(target_key: rows.map { |row| TagManager.instance.normalize_domain(row['#domain']) }).delete_all

      subscription.touch(:last_synced_at)

      true
    end
  rescue *Mastodon::HTTP_CONNECTION_ERRORS => e
    Rails.logger.warn "Failed syncing moderation subscription #{subscription.url}: #{e}"

    false
  end

  def action_from_severity(subscription, row)
    return subscription.list_action if subscription.list_action.present?

    case row['#severity']
    when 'accept', 'allow'
      'accept'
    when 'limit', 'silence'
      'limit'
    else
      'reject'
    end
  end
end
