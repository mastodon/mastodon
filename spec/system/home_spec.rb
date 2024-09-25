# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home page' do
  context 'when signed in' do
    before { sign_in Fabricate(:user) }

    it 'visits the homepage and renders the web app' do
      visit root_path

      expect(page)
        .to have_css('noscript', text: /Mastodon/)
    end
  end

  context 'when not signed in' do
    it 'visits the homepage and renders the web app' do
      visit root_path

      expect(page)
        .to have_css('noscript', text: /Mastodon/)
    end
  end
end
