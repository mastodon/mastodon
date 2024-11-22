# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::Discovery' do
  it 'Saves changes to discovery settings' do
    sign_in admin_user
    visit admin_settings_discovery_path

    check trends_box

    click_on submit_button

    expect(page)
      .to have_content(success_message)
  end

  def trends_box
    form_label 'form_admin_settings.trends'
  end
end
