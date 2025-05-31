# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Recognizing text', :attachment_processing, :inline_jobs, :js, :streaming do
  include ProfileStories

  let(:email)               { 'test@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }

  before { as_a_logged_in_user }

  it 'uses text OCR during media attachment' do
    visit root_path
    expect(page)
      .to have_css('div.app-holder')

    attach_file('file-upload-input', file_fixture('text.png'), make_visible: true)
    expect(page)
      .to have_css('.compose-form__upload__actions button', text: 'Edit')

    within('.compose-form__upload') { click_on('Edit') }
    expect(page)
      .to have_content('Add alt text')

    click_on('Add text from image')
    expect(page)
      .to have_css('#description', text: /Hello Mastodon\s*/, wait: 10)
  end
end
