# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings preferences appearance page' do
  let(:user) { Fabricate :user }

  before { sign_in user }

  it 'Views and updates user prefs' do
    visit settings_preferences_appearance_path

    expect(page)
      .to have_private_cache_control

    check confirm_reblog_field
    uncheck confirm_delete_field

    check advanced_layout_field

    expect { save_changes }
      .to change { user.reload.settings['web.reblog_modal'] }.to(true)
      .and change { user.reload.settings['web.delete_modal'] }.to(false)
      .and(change { user.reload.settings['web.advanced_layout'] }.to(true))
    expect(page)
      .to have_title(I18n.t('settings.appearance'))
  end

  def save_changes
    within('form') { click_on submit_button }
  end

  def confirm_delete_field
    form_label('defaults.setting_delete_modal')
  end

  def confirm_reblog_field
    form_label('defaults.setting_boost_modal')
  end

  def theme_selection_field
    form_label('defaults.setting_theme')
  end

  def advanced_layout_field
    form_label('defaults.setting_advanced_layout')
  end
end
