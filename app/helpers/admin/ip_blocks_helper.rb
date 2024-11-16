# frozen_string_literal: true

module Admin::IpBlocksHelper
  def ip_blocks_severity_label(severity)
    safe_join(
      [
        I18n.t("simple_form.labels.ip_block.severities.#{severity}"),
        content_tag(:span, I18n.t("simple_form.hints.ip_block.severities.#{severity}"), class: 'hint'),
      ]
    )
  end

  def ip_blocks_expires_options
    [1.day, 2.weeks, 1.month, 6.months, 1.year, 3.years]
  end
end
