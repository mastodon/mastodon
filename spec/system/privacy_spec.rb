# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Privacy policy page' do
  it 'visits the privacy policy page and renders the web app' do
    visit privacy_policy_path

    expect(page)
      .to have_css('noscript', text: /Mastodon/)
  end
end
