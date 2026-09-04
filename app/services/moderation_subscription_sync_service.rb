# frozen_string_literal: true

class ModerationSubscriptionSyncService < BaseService
  def call(subscription)
    case subscription.type
    when 'csv_list'
      synchronize_csv_moderation_subscription!(subscription)
    when 'json'
      synchronize_json_moderation_subscription!(subscription)
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
        when '#domain', '#severity'
          field&.downcase&.strip
        when '#public_comment'
          field&.strip
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

      advisories = rows.filter_map do |row|
        action = action_from_severity(subscription, row['#severity'])
        next if action.blank?

        {
          target_key: TagManager.instance.normalize_domain(row['#domain']),
          target_type: 'domain',
          moderation_subscription_id: subscription.id,
          action: action,
        }
      end

      synchronize_advisories(subscription, advisories)
    end
  rescue *Mastodon::HTTP_CONNECTION_ERRORS => e
    Rails.logger.warn "Failed syncing moderation subscription #{subscription.url}: #{e}"

    false
  end

  def synchronize_json_moderation_subscription!(subscription)
    Request.new(:get, subscription.url).add_headers('Accept' => 'application/json').perform do |res|
      return false unless res.code == 200

      data = JSON.parse(res.body_with_limit)
      return false unless data.is_a?(Array)

      advisories = data.filter_map do |block|
        action = action_from_severity(subscription, block['severity'])
        next if action.blank?

        {
          target_key: TagManager.instance.normalize_domain(block['domain']),
          target_type: 'domain',
          moderation_subscription_id: subscription.id,
          action: action,
        }
      end

      synchronize_advisories(subscription, advisories)
    end
  rescue JSON::ParserError, *Mastodon::HTTP_CONNECTION_ERRORS => e
    Rails.logger.warn "Failed syncing moderation subscription #{subscription.url}: #{e}"

    false
  end

  def synchronize_advisories(subscription, advisories)
    SubscribedAdvisory.upsert_all(
      advisories,
      unique_by: [:target_type, :target_key, :moderation_subscription_id]
    )

    SubscribedAdvisory::TARGET_TYPES.each do |target_type|
      subscription.advisories.where(target_type: target_type).where.not(target_key: advisories.filter_map { |advisory| advisory[:target_key] if advisory[:target_type] == target_type }).delete_all
    end

    subscription.touch(:last_synced_at)

    true
  end

  def action_from_severity(subscription, severity)
    case severity
    when '', nil
      subscription.list_action || 'reject'
    when 'accept', 'allow'
      'accept' unless subscription.list_action == 'reject'
    when 'limit', 'silence'
      'limit' unless subscription.list_action == 'accept'
    when 'block', 'reject', 'suspend'
      'reject' unless subscription.list_action == 'accept'
    end
  end
end
