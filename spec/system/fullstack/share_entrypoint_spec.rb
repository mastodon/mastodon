# frozen_string_literal: true

require 'rails_helper'

describe 'ShareEntrypoint' do
  include ProfileStories

  subject { page }

  let(:email)               { 'test@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }

  before do
    as_a_logged_in_user
    visit share_path
  end

  it 'can be used to post a new status' do
    expect(subject).to have_css('div#mastodon-compose')
    expect(subject).to have_css('.compose-form__submit')

    status_text = 'This is a new status!'

    within('.compose-form') do
      fill_in "What's on your mind?", with: status_text
      click_on 'Post'
    end

    expect(subject).to have_css('.notification-bar-message', text: 'Post published.')
  end
end
