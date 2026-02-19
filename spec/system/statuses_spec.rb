# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Status page' do
  let(:status) { Fabricate :status }

  it 'visits the status page and renders the web app' do
    visit short_account_status_path(account_username: status.account.username, id: status.id)

    expect(page)
      .to have_css('noscript', text: /Mastodon/)
      .and have_css('body', class: 'app-body')
  end
end
