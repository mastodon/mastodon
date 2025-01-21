# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'alt-text modal', :attachment_processing, :inline_jobs, :js, :streaming do
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

    status_text = 'This is a new status!'

    within('.compose-form') do
      fill_in "What's on your mind?", with: status_text

      attach_file('file-upload-input', file_fixture('text.png'), make_visible: true)

      within('.compose-form__upload') do
        click_on('Edit')
      end
    end

    # Starting to type something and hitting escape…
    within('.dialog-modal') do
      fill_in 'description', with: 'hello'
      find_by_id('description').send_keys(:escape)
    end

    # … should bring up the confirmation modal
    expect(page).to have_css('.safety-action-modal__confirmation', text: 'You have unsaved changes')
    click_on('Cancel')

    # Media modal should be brought up again with in-progress text
    within('.dialog-modal') do
      expect(page).to have_css('#description', text: 'hello')
      fill_in 'description', with: 'Hello Masto'

      click_on('Done')
    end

    # Media modal should be brought up again with latest text
    within('.compose-form .compose-form__upload') do
      click_on('Edit')
    end

    within('.dialog-modal') do
      expect(page).to have_css('#description', text: 'Hello Masto')
      fill_in 'description', with: 'Hello Mastodon'

      click_on('Done')
    end

    # Posting should work
    within('.compose-form') do
      click_on 'Post'
    end

    # TODO: check image description
    expect(subject).to have_css('.status__content__text', text: status_text)
    expect(subject).to have_css('.media-gallery__item-thumbnail img', text: 'Hello Mastodon')

    # TODO: check that edit still works
  end
end
