# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::About' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  it 'Saves changes to about settings' do
    visit admin_settings_about_path
    expect(page)
      .to have_title(I18n.t('admin.settings.about.title'))

    fill_in site_terms_field,
            with: 'Updated terms for Highlander'

    expect { click_on submit_button }
      .to change(Setting, :site_terms).to('Updated terms for Highlander')

    expect(page)
      .to have_text(success_message)
  end

  def site_terms_field
    form_label 'form_admin_settings.site_terms'
  end
end
