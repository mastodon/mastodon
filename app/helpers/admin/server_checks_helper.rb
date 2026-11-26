# frozen_string_literal: true

module Admin::ServerChecksHelper
  ICONS = {
    'critical' => 'error',
    'warning' => 'warning',
    'suggestion' => 'lightbulb_circle',
    'error' => 'dangerous',
    'completed' => 'check_circle',
    'unprocessed' => 'pending',
    'ignored' => 'block',
  }.freeze

  def admin_server_check_title(check)
    t("admin.server_checks.checks.#{check.key}.#{check.status}.title")
  end

  def admin_server_check_lead(check)
    return admin_server_check_error(check) if check.error?
    return nil unless check.pending?

    data = check.data.symbolize_keys

    if data[:reason].present?
      t("admin.server_checks.checks.#{check.key}.#{check.status}.lead.#{data[:reason]}_html", **data)
    else
      t("admin.server_checks.checks.#{check.key}.#{check.status}.lead_html", **data)
    end
  end

  def admin_server_check_error(check)
    check.data['error']
  end

  def admin_server_check_setup(check)
    url = admin_server_check_setup_url(check)

    link_to(t('admin.server_checks.setup.label'), url, class: %w(button)) if url.present?
  end

  def admin_server_check_setup_url(check)
    case check.key
    when 'rules'
      admin_rules_url
    when 'elastic_search'
      'https://docs.joinmastodon.org/admin/elasticsearch/#scaling' if check.data['reason']&.in?(%w(preset_single_node preset))
    when 'media_privacy'
      if check.data['reason'] == 'upload_check_privacy_error_object_storage'
        'https://docs.joinmastodon.org/admin/optional/object-storage/#S3'
      else
        'https://docs.joinmastodon.org/admin/optional/object-storage/#FS'
      end
    when 'software_version'
      admin_software_updates_url
    end
  end

  def admin_server_check_ignore_action(check)
    label = t('admin.server_checks.ignore.label')
    method = :post
    if check.ignored?
      label = t('admin.server_checks.restore.label')
      method = :delete
    end

    link_to label, admin_ignored_server_check_path(key: check.key), method:, class: %w(button button-secondary)
  end

  def admin_server_check_icon(category)
    icon = ICONS[category]

    material_symbol(icon)
  end
end
