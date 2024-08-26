# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::Branding' do
  it 'Saves changes to branding settings' do
    sign_in admin_user
    visit admin_settings_branding_path

    fill_in short_description_field,
            with: 'new key value'

    fill_in site_contact_email_field,
            with: User.last.email

    fill_in site_contact_username_field,
            with: Account.last.username

    expect { click_on submit_button }
      .to change(Setting, :site_short_description).to('new key value')

    expect(page)
      .to have_content(success_message)
  end

  def short_description_field
    form_label 'form_admin_settings.site_short_description'
  end

  def site_contact_email_field
    form_label 'form_admin_settings.site_contact_email'
  end

  def site_contact_username_field
    form_label 'form_admin_settings.site_contact_username'
  end
end
