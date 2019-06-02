# frozen_string_literal: true

module Admin::DashboardHelper
  def feature_hint(feature, enabled)
    indicator   = safe_join([enabled ? t('simple_form.yes') : t('simple_form.no'), fa_icon('power-off fw')], ' ')
    class_names = enabled ? 'pull-right positive-hint' : 'pull-right neutral-hint'

    safe_join([feature, content_tag(:span, indicator, class: class_names)])
  end
end
