# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings preferences appearance page' do
  let(:user) { Fabricate :user }

  before { sign_in user }

  it 'Views and updates user prefs' do
    visit settings_preferences_appearance_path

    expect(page)
      .to have_private_cache_control

    select 'contrast', from: theme_selection_field
    check confirm_reblog_field
    uncheck confirm_delete_field

    expect { save_changes }
      .to change { user.reload.settings.theme }.to('contrast')
      .and change { user.reload.settings['web.reblog_modal'] }.to(true)
      .and(change { user.reload.settings['web.delete_modal'] }.to(false))
    expect(page)
      .to have_title(I18n.t('settings.appearance'))
  end

  def save_changes
    within('form') { click_on submit_button }
  end

  def confirm_delete_field
    I18n.t('simple_form.labels.defaults.setting_delete_modal')
  end

  def confirm_reblog_field
    I18n.t('simple_form.labels.defaults.setting_boost_modal')
  end

  def theme_selection_field
    I18n.t('simple_form.labels.defaults.setting_theme')
  end
end
