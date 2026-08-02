# frozen_string_literal: true

module NotificationFallbackConcern
  extend ActiveSupport::Concern

  def fallback
    {
      title: fallback_title,
      summary: fallback_summary,
      description: nil,
    }
  end

  def needs_fallback?
    return false if instance_options[:supported_notification_types].nil?
    return false if Notification::PROPERTIES.dig(object.type, :baseline) || instance_options[:supported_notification_types].include?(object.type.to_s)

    # In rare cases, a notification might be missing its activity, in which case we can't do much
    case object.type
    when :severed_relationships
      object.account_relationship_severance_event.present?
    when :'admin.report'
      object.report.present?
    when :added_to_collection, :collection_update
      object.target_collection.present?
    else
      true
    end
  end

  def fallback_title
    account = object.is_a?(NotificationGroup) ? object.sample_accounts.first : object.from_account

    case object.type
    when :severed_relationships
      I18n.t(
        'notification_fallbacks.severed_relationships.title',
        name: object.account_relationship_severance_event.target_name
      )
    when :moderation_warning
      I18n.t('notification_fallbacks.moderation_warning.title')
    when :'admin.sign_up'
      count = object.is_a?(NotificationGroup) ? object.sample_accounts.count : 1
      if count > 1
        I18n.t(
          'notification_fallbacks.admin_sign_up.title_and_others_html',
          name: TextFormatter.link_to_mention(account),
          count: count - 1
        )
      else
        I18n.t(
          'notification_fallbacks.admin_sign_up.title_html',
          name: TextFormatter.link_to_mention(account)
        )
      end
    when :'admin.report'
      I18n.t(
        'notification_fallbacks.admin_report.title_html',
        name: account.remote? ? account.domain : TextFormatter.link_to_mention(account),
        target: TextFormatter.link_to_mention(object.report.target_account)
      )
    when :added_to_collection
      I18n.t(
        'notification_fallbacks.added_to_collection.title_html',
        name: TextFormatter.link_to_mention(account)
      )
    when :collection_update
      I18n.t(
        'notification_fallbacks.collection_update.title_html',
        name: account
      )
    end
  end

  def fallback_summary
    case object.type
    when :severed_relationships
      I18n.t(
        'notification_fallbacks.severed_relationships.summary_html',
        from: Rails.configuration.x.local_domain,
        target: object.account_relationship_severance_event.target_name,
        link: link_to(I18n.t('notification_fallbacks.generic.sign_in'), severed_relationships_url)
      )
    when :moderation_warning
      I18n.t(
        'notification_fallbacks.moderation_warning.summary_html',
        link: link_to(I18n.t('notification_fallbacks.generic.sign_in'), disputes_strike_url(object.account_warning.id))
      )
    when :'admin.sign_up', :'admin.report', :added_to_collection, :collection_update
      I18n.t(
        'notification_fallbacks.generic.summary_html',
        link: link_to(I18n.t('notification_fallbacks.generic.sign_in'), root_url)
      )
    end
  end
end
