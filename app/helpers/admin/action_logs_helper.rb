# frozen_string_literal: true

module Admin::ActionLogsHelper
  def log_target(log)
    case log.target_type
    when 'Account'
      link_to (log.human_identifier.presence || I18n.t('admin.action_logs.deleted_account')), admin_account_path(log.target_id)
    when 'User'
      if log.route_param.present?
        link_to log.human_identifier, admin_account_path(log.route_param)
      else
        I18n.t('admin.action_logs.deleted_account')
      end
    when 'UserRole'
      link_to log.human_identifier, admin_roles_path(log.target_id)
    when 'Report'
      link_to "##{log.human_identifier.presence || log.target_id}", admin_report_path(log.target_id)
    when 'DomainBlock', 'DomainAllow', 'EmailDomainBlock', 'UnavailableDomain'
      link_to log.human_identifier, "https://#{log.human_identifier.presence}", data: { confirm: t('admin.action_logs.external_link', url: "https//#{log.human_identifier.presence}") }
    when 'Status'
      if log.permalink.blank? || TagManager.instance.local_url?(log.permalink)
        link_to log.human_identifier, log.permalink
      else
        link_to log.human_identifier, log.permalink, data: { confirm: t('admin.action_logs.external_link', url: log.permalink) }
      end
    when 'AccountWarning'
      link_to log.human_identifier, disputes_strike_path(log.target_id)
    when 'Announcement'
      link_to truncate(log.human_identifier), edit_admin_announcement_path(log.target_id)
    when 'IpBlock', 'Instance', 'CustomEmoji'
      log.human_identifier
    when 'CanonicalEmailBlock'
      content_tag(:samp, (log.human_identifier.presence || '')[0...7], title: log.human_identifier)
    when 'Appeal'
      if log.route_param.present?
        link_to log.human_identifier, disputes_strike_path(log.route_param.presence)
      else
        I18n.t('admin.action_logs.deleted_account')
      end
    end
  end
end
