# frozen_string_literal: true

module SystemHelpers
  def admin_user
    Fabricate(:admin_user)
  end

  def submit_button
    I18n.t('generic.save_changes')
  end

  def success_message
    I18n.t('generic.changes_saved_msg')
  end

  def form_label(key)
    I18n.t key, scope: 'simple_form.labels'
  end

  def css_id(record)
    "##{dom_id(record)}"
  end
end
