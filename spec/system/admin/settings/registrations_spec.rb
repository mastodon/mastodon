# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::Registrations' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  it 'Saves changes to registrations settings' do
    visit admin_settings_registrations_path
    expect(page)
      .to have_title(I18n.t('admin.settings.registrations.title'))

    select open_mode_option,
           from: registrations_mode_field

    click_on submit_button

    expect(page)
      .to have_content(success_message)
  end

  def open_mode_option
    I18n.t('admin.settings.registrations_mode.modes.open')
  end

  def registrations_mode_field
    form_label 'form_admin_settings.registrations_mode'
  end
end
