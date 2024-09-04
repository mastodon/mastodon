# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::About' do
  it 'Saves changes to about settings' do
    sign_in admin_user
    visit admin_settings_about_path

    fill_in extended_description_field,
            with: 'new site description'

    click_on submit_button

    expect(page)
      .to have_content(success_message)
  end

  def extended_description_field
    form_label 'form_admin_settings.site_extended_description'
  end
end
