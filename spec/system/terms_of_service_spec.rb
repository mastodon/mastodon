# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Terms of Service page' do
  it 'visits the about page and renders the web app' do
    visit terms_of_service_path

    expect(page)
      .to have_css('noscript', text: /Mastodon/)
      .and have_css('body', class: 'app-body')
  end
end
