# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OCR', :attachment_processing, :inline_jobs, :js, :streaming do
  include ProfileStories

  let(:email)               { 'test@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }

  before do
    as_a_logged_in_user
    visit root_path
  end

  it 'can recognize text in a media attachment' do
    expect(page).to have_css('div.app-holder')

    within('nav') do
      click_on frontend_translations('tabs_bar.publish')
    end

    within('form[role="dialog"]') do
      attach_file(file_fixture('text.png')) do
        click_on(frontend_translations('upload_button.label'))
      end

      click_on('Add alt text')
    end

    click_on('Add text from image')

    expect(page).to have_css('#description', text: /Hello Mastodon\s*/, wait: 20)
  end
end
