# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::Appearance' do
  it 'Saves changes to appearance settings' do
    sign_in admin_user
    visit admin_settings_appearance_path

    fill_in custom_css_field,
            with: 'html { display: inline; }'

    click_on submit_button

    expect(page)
      .to have_content(success_message)
  end

  def custom_css_field
    form_label 'form_admin_settings.custom_css'
  end
end
