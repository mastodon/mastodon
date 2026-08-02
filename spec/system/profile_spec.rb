# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profile' do
  include ProfileStories

  before do
    as_a_logged_in_user
    Fabricate(:user, account: Fabricate(:account, username: 'alice'))
  end

  it 'I can view public account page for Alice' do
    visit account_path('alice')

    expect(page)
      .to have_title("alice (@alice@#{local_domain_uri.host})")
  end
end
