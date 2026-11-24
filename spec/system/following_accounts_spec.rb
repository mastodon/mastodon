# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account following page' do
  let(:account) { Fabricate(:account) }

  describe 'Viewing followed accounts' do
    it 'renders the web app' do
      visit "/@#{account.username}/following"

      expect(page)
        .to have_css('noscript', text: /Mastodon/)
        .and have_css('body', class: 'app-body')
    end
  end
end
