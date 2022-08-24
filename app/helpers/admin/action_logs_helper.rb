# frozen_string_literal: true

module Admin::ActionLogsHelper
  def log_target(log)
    case log.target_type
    when 'Account'
      link_to log.human_identifier, admin_account_path(log.target_id)
    when 'User'
      link_to log.human_identifier, admin_account_path(log.route_param)
    when 'CustomEmoji'
      log.human_identifier
    when 'Report'
      link_to "##{log.human_identifier}", admin_report_path(log.target_id)
    when 'DomainBlock', 'DomainAllow', 'EmailDomainBlock', 'UnavailableDomain'
      link_to log.human_identifier, "https://#{log.human_identifier}"
    when 'Status'
      link_to log.human_identifier, log.permalink
    when 'AccountWarning'
      link_to log.human_identifier, admin_account_path(log.target_id)
    when 'Announcement'
      link_to truncate(log.human_identifier), edit_admin_announcement_path(log.target_id)
    when 'IpBlock'
      log.human_identifier
    when 'Instance'
      log.human_identifier
    when 'Appeal'
      link_to log.human_identifier, disputes_strike_path(log.route_param)
    end
  end
end
