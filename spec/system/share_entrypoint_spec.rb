# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Share page', :js, :streaming do
  include ProfileStories

  let(:email)               { 'test@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }

  before { as_a_logged_in_user }

  it 'allows posting a new status' do
    visit share_path

    expect(page)
      .to have_css('.modal-layout__mastodon')
      .and have_css('div#mastodon-compose')
      .and have_css('.compose-form__submit')

    fill_in_form

    expect(page)
      .to have_css('.notification-bar-message', text: translations['compose.published.body'])
  end

  def fill_in_form
    within('.compose-form') do
      fill_in translations['compose_form.placeholder'],
              with: 'This is a new status!'
      click_on translations['compose_form.publish']
    end
  end

  def translations
    # TODO: Extract to system spec helper for re-use?
    JSON.parse(
      Rails
        .root
        .join('app', 'javascript', 'mastodon', 'locales', 'en.json')
        .read
    )
  end
end
