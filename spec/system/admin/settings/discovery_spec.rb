# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::Discovery' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  it 'Saves changes to discovery settings' do
    visit admin_settings_discovery_path
    expect(page)
      .to have_title(I18n.t('admin.settings.discovery.title'))

    check trends_box

    click_on submit_button

    expect(page)
      .to have_content(success_message)
  end

  def trends_box
    form_label 'form_admin_settings.trends'
  end
end
