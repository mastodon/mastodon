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

  it 'I can change my account' do
    visit settings_profile_path

    fill_in 'Display name', with: 'Bob'
    fill_in 'Bio', with: 'Bob is silent'

    account_fields_labels.first.fill_in with: 'Personal Website'
    account_fields_values.first.fill_in with: 'https://host.example/personal'

    account_fields_labels.last.fill_in with: 'Professional Biography'
    account_fields_values.last.fill_in with: 'https://host.example/pro'

    expect { submit_form }
      .to change { bob.account.reload.display_name }.to('Bob')
      .and(change_account_fields)
    expect(page)
      .to have_content 'Changes successfully saved!'
  end

  def submit_form
    first('button[type=submit]').click
  end

  def account_fields_labels
    page.all('.account_fields_name input')
  end

  def account_fields_values
    page.all('.account_fields_value input')
  end

  def change_account_fields
    change { bob.account.reload.fields }
      .from([])
      .to(
        contain_exactly(
          be_a(Account::Field),
          be_a(Account::Field)
        )
      )
  end
end
