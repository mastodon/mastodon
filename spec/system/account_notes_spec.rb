# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account notes', :inline_jobs, :js, :streaming do
  include ProfileStories

  let(:email)               { 'test@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }

  let!(:other_account) { Fabricate(:account) }
  let(:note_text) { 'This is a personal note' }

  before { as_a_logged_in_user }

  it 'can be written and viewed' do
    visit_profile(other_account)

    fill_in frontend_translations('account_note.placeholder'), with: note_text

    # This is a bit awkward since there is no button to save the change
    # The easiest way is to send ctrl+enter ourselves
    find_field(class: 'account__header__account-note__content').send_keys [:control, :enter]

    expect(page)
      .to have_css('.account__header__account-note__content', text: note_text)

    # Navigate back and forth and ensure the comment is still here
    visit root_url
    visit_profile(other_account)

    expect(AccountNote.find_by(account: bob.account, target_account: other_account).comment)
      .to eq note_text

    expect(page)
      .to have_css('.account__header__account-note__content', text: note_text)
  end

  def visit_profile(account)
    visit short_account_path(account)

    expect(page)
      .to have_css('div.app-holder')
      .and have_css('form.compose-form')
  end
end
