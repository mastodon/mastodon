# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account notes', :inline_jobs, :js, :streaming do
  include ProfileStories

  let(:email)               { 'test@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }
  let(:note_text) { 'This is a personal note' }

  let!(:other_account) { Fabricate(:account) }
  let!(:status) { Fabricate :status, account: other_account }

  before { as_a_logged_in_user }

  it 'can be written and viewed' do
    visit_profile(other_account)
    expect(page)
      .to have_content(other_account.username)

    # Fill in account note, submit with ctrl+enter (no button), verify page update
    fill_in frontend_translations('account_note.placeholder'), with: note_text
    find_field(class: 'account__header__account-note__content').send_keys [:control, :enter]
    expect(page)
      .to have_css('.account__header__account-note__content', text: note_text)

    # Navigate to feed page
    click_on 'Live feeds'
    expect(page)
      .to have_content(status.text)

    # Return to profile page, verify note still present
    click_on other_account.username
    expect(page)
      .to have_css('.account__header__account-note__content', text: note_text)

    # Verify db record update
    expect(AccountNote.find_by(account: bob.account, target_account: other_account).comment)
      .to eq(note_text)
  end

  def visit_profile(account)
    visit short_account_path(account)

    expect(page)
      .to have_css('div.app-holder')
      .and have_css('form.compose-form')
  end
end
