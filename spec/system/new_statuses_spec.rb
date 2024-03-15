# frozen_string_literal: true

require 'rails_helper'

describe 'NewStatuses', :sidekiq_inline do
  include ProfileStories

  subject { page }

  let(:email)               { 'test@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }

  before do
    as_a_logged_in_user
    visit root_path
  end

  it 'can be posted' do
    expect(subject).to have_css('div.app-holder')

    status_text = 'This is a new status!'

    within('.compose-form') do
      fill_in "What's on your mind?", with: status_text
      click_on 'Post'
    end

    expect(subject).to have_css('.status__content__text', text: status_text)
  end

  it 'can be posted again' do
    expect(subject).to have_css('div.app-holder')

    status_text = 'This is a second status!'

    within('.compose-form') do
      fill_in "What's on your mind?", with: status_text
      click_on 'Post'
    end

    expect(subject).to have_css('.status__content__text', text: status_text)
  end
end
