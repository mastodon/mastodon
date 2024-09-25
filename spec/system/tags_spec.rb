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
        .and have_private_cache_control
    end
  end
end
