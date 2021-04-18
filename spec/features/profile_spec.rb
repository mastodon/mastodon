# frozen_string_literal: true

require 'rails_helper'

feature 'Profile' do
  include ProfileStories

  given(:local_domain) { ENV['LOCAL_DOMAIN'] }

  background do
    as_a_logged_in_user
    with_alice_as_local_user
  end

  subject { page }

  scenario 'I can view Annes public account' do
    visit account_path('alice')

    is_expected.to have_title("alice (@alice@#{local_domain})")

    within('.public-account-header h1') do
      is_expected.to have_content("alice @alice@#{local_domain}")
    end

    bio_elem = first('.public-account-bio')
    expect(bio_elem).to have_content(alice_bio)
    # The bio has hashtags made clickable
    expect(bio_elem).to have_link('cryptology')
    expect(bio_elem).to have_link('science')
    # Nicknames are make clickable
    expect(bio_elem).to have_link('@alice')
    expect(bio_elem).to have_link('@bob')
    # Nicknames not on server are not clickable
    expect(bio_elem).not_to have_link('@pepe')
  end

  scenario 'I can change my account' do
    visit settings_profile_path
    fill_in 'Display name', with: 'Bob'
    fill_in 'Bio', with: 'Bob is silent'
    first('.btn[type=submit]').click
    is_expected.to have_content 'Changes successfully saved!'

    # View my own public profile and see the changes
    click_link "Bob @bob@#{local_domain}"

    within('.public-account-header h1') do
      is_expected.to have_content("Bob @bob@#{local_domain}")
    end
    expect(first('.public-account-bio')).to have_content('Bob is silent')
  end
end
