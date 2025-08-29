# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'finding software updates through the admin interface' do
  before { sign_in Fabricate(:owner_user) }

  let!(:latest_release) { Fabricate(:software_update, version: '99.99.99', type: 'major', urgent: true, release_notes: 'https://github.com/mastodon/mastodon/releases/v99') }
  let!(:other_release) { Fabricate(:software_update, version: '98.0.0', type: 'major', release_notes: '') }
  let!(:outdated_release) { Fabricate(:software_update, version: '3.5.0', type: 'major', urgent: true, release_notes: 'https://github.com/mastodon/mastodon/releases/v3.5.0') }

  it 'shows a link to the software updates page, which links to release notes' do
    visit settings_profile_path
    click_on I18n.t('admin.critical_update_pending')

    expect(page)
      .to have_title(I18n.t('admin.software_updates.title'))
      .and have_content(latest_release.version)
      .and have_content(other_release.version)
      .and have_no_content(outdated_release.version)

    within("#software_update_#{other_release.id}") do
      expect(find('.release-notes').value).to be_nil
    end

    click_on I18n.t('admin.software_updates.release_notes')
    expect(page)
      .to have_current_path('https://github.com/mastodon/mastodon/releases/v99', url: true)
  end
end
