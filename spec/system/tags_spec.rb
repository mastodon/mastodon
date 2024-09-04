# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tags' do
  describe 'Viewing a tag' do
    let(:tag) { Fabricate(:tag, name: 'test') }

    before { sign_in Fabricate(:user) }

    it 'visits the tag page and renders the web app' do
      visit tag_path(tag)

      expect(page)
        .to have_css('noscript', text: /Mastodon/)
      expect(page.response_headers)
        .to include('Cache-Control' => 'private, no-store')
    end
  end
end
