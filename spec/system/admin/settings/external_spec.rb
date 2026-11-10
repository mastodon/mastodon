# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::External' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  it 'saves changes to external discovery settings' do
    visit admin_settings_external_path
    expect(page)
      .to have_title(I18n.t('admin.settings.external.title'))

    uncheck activity_api_enabled_box

    expect { click_on submit_button }
      .to change(Setting, :activity_api_enabled).from(true).to(false)
    expect(page)
      .to have_title(I18n.t('admin.settings.external.title'))
      .and have_text(success_message)
    expect(page)
      .to have_unchecked_field(activity_api_enabled_box)
  end

  def activity_api_enabled_box
    form_label 'form_admin_settings.activity_api_enabled'
  end
end
