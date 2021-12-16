# frozen_string_literal: true

module Admin::DashboardHelper
  def relevant_account_ip(account, ip_query)
    default_ip = [account.user_current_sign_in_ip || account.user_sign_up_ip]

    matched_ip = begin
      ip_query_addr = IPAddr.new(ip_query)
      account.user.recent_ips.find { |(_, ip)| ip_query_addr.include?(ip) } || default_ip
    rescue IPAddr::Error
      default_ip
    end.last

    if matched_ip
      link_to matched_ip, admin_accounts_path(ip: matched_ip)
    else
      '-'
    end
  end

  def relevant_account_timestamp(account)
    timestamp, exact = begin
      if account.user_current_sign_in_at && account.user_current_sign_in_at < 24.hours.ago
        [account.user_current_sign_in_at, true]
      elsif account.user_current_sign_in_at
        [account.user_current_sign_in_at, false]
      elsif account.user_pending?
        [account.user_created_at, true]
      elsif account.last_status_at.present?
        [account.last_status_at, true]
      else
        [nil, false]
      end
    end

    return '-' if timestamp.nil?
    return t('generic.today') unless exact

    content_tag(:time, l(timestamp), class: 'time-ago', datetime: timestamp.iso8601, title: l(timestamp))
  end
end
