# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profile' do
  include ProfileStories

  subject { page }

  let(:local_domain) { Rails.configuration.x.local_domain }

  before do
    as_a_logged_in_user
    Fabricate(:user, account: Fabricate(:account, username: 'alice'))
  end

  it 'I can view public account page for Alice' do
    visit account_path('alice')

    expect(subject).to have_title("alice (@alice@#{local_domain})")
  end

  it 'I can change my account' do
    visit settings_profile_path

    fill_in 'Display name', with: 'Bob'
    fill_in 'Bio', with: 'Bob is silent'

    first('button[type=submit]').click

    expect(subject).to have_content 'Changes successfully saved!'
  end
end
