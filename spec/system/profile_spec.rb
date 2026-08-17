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
