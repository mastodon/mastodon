# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'About page' do
  it 'visits the about page and renders the web app' do
    visit about_path

    expect(page)
      .to have_css('noscript', text: /Mastodon/)
  end
end
