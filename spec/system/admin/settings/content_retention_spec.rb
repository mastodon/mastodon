# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::ContentRetention' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  it 'Saves changes to content retention settings' do
    visit admin_settings_content_retention_path
    expect(page)
      .to have_title(I18n.t('admin.settings.content_retention.title'))

    fill_in media_cache_retention_period_field,
            with: '2'

    click_on submit_button

    expect(page)
      .to have_content(success_message)
  end

  def media_cache_retention_period_field
    form_label 'form_admin_settings.media_cache_retention_period'
  end
end
