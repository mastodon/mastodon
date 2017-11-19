# frozen_string_literal: true

module Admin::ActionLogsHelper
  def linkable_log_target(record)
    case record.class.name
    when 'Account'
      link_to "@#{record.acct}", admin_account_path(record.id)
    when 'User'
      link_to "@#{record.account.acct}", admin_account_path(record.account_id)
    when 'CustomEmoji'
      [":#{record.shortcode}:", record.domain].compact.join('@')
    when 'Report'
      link_to "##{record.id}", admin_report_path(record)
    end
  end
end
