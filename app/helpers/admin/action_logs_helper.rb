# frozen_string_literal: true

module Admin::ActionLogsHelper
  def linkable_log_target(record)
    case record.class.name
    when 'Account'
      link_to "@#{record.acct}", admin_account_path(record.id)
    when 'User'
      link_to "@#{record.account.acct}", admin_account_path(record.account_id)
    when 'CustomEmoji'
      ":#{record.shortcode}:"
    when 'Report'
      link_to "##{record.id}", admin_report_path(record)
    when 'DomainBlock', 'EmailDomainBlock'
      link_to record.domain, "https://#{record.domain}"
    when 'Status'
      link_to ActivityPub::TagManager.instance.uri_for(record), TagManager.instance.url_for(record)
    end
  end

  def log_target_from_history(type, attributes)
    case type
    when 'CustomEmoji'
      ":#{attributes['shortcode']}:"
    when 'DomainBlock', 'EmailDomainBlock'
      link_to attributes['domain'], "https://#{attributes['domain']}"
    when 'Status'
      tmp_status = Status.new(attributes)
      link_to ActivityPub::TagManager.instance.uri_for(tmp_status), TagManager.instance.url_for(tmp_status)
    end
  end

  def relevant_log_changes(log)
    if log.target_type == 'CustomEmoji' && [:enable, :disable, :destroy].include?(log.action)
      log.recorded_changes.slice('domain')
    elsif log.target_type == 'CustomEmoji' && log.action == :update
      log.recorded_changes.slice('domain', 'visible_in_picker')
    elsif log.target_type == 'User' && [:promote, :demote].include?(log.action)
      log.recorded_changes.slice('moderator', 'admin')
    elsif log.target_type == 'DomainBlock'
      log.recorded_changes.slice('severity', 'reject_media')
    elsif log.target_type == 'Status' && log.action == :update
      log.recorded_changes.slice('sensitive')
    end
  end

  def log_extra_attributes(hash)
    safe_join(hash.to_a.map { |key, value| safe_join([content_tag(:span, key, class: 'diff-key'), '=', log_change(value)]) }, ' ')
  end

  def log_change(val)
    return content_tag(:span, val, class: 'diff-neutral') unless val.is_a?(Array)
    safe_join([content_tag(:span, val.first, class: 'diff-old'), content_tag(:span, val.last, class: 'diff-new')], '→')
  end
end
