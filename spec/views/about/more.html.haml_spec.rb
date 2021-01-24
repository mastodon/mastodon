# frozen_string_literal: true

require 'rails_helper'

describe 'about/more.html.haml', without_verify_partial_doubles: true do
  around do |example|
    activity_api_enabled = Setting.activity_api_enabled
    example.run
    Setting.activity_api_enabled = activity_api_enabled
  end

  before do
    allow(view).to receive(:site_hostname).and_return('example.com')
    allow(view).to receive(:site_title).and_return('example site')
    allow(view).to receive(:new_user).and_return(User.new)
    allow(view).to receive(:use_seamless_external_login?).and_return(false)
    allow(view).to receive(:display_blocks?).and_return(false)

    instance_presenter = double(
      :instance_presenter,
      site_contact_email: 'admin@example.com',
      site_title: 'something',
      site_short_description: 'something',
      site_description: 'something',
      version_number: '1.0',
      source_url: 'https://github.com/tootsuite/mastodon',
      open_registrations: false,
      thumbnail: nil,
      hero: nil,
      mascot: nil,
      user_count: 420,
      status_count: 69,
      active_user_count: 420,
      contact_account: nil,
      sample_accounts: []
    )

    assign(:instance_presenter, instance_presenter)
    assign(:table_of_contents, [])
  end

  context 'when activity api is enabled' do
    before do
      Setting.activity_api_enabled = true
    end

    it 'displays aggregate statistics about user activity' do
      render

      expect(rendered).to have_css('.information-board__section:nth-child(1) *:nth-child(1)', text: 'Home to')
      expect(rendered).to have_css('.information-board__section:nth-child(1) *:nth-child(2)', text: '420')
      expect(rendered).to have_css('.information-board__section:nth-child(1) *:nth-child(3)', text: 'users')

      expect(rendered).to have_css('.information-board__section:nth-child(2) *:nth-child(1)', text: 'Who authored')
      expect(rendered).to have_css('.information-board__section:nth-child(2) *:nth-child(2)', text: '69')
      expect(rendered).to have_css('.information-board__section:nth-child(2) *:nth-child(3)', text: 'statuses')
    end
  end

  context 'when activity api is disabled' do
    before do
      Setting.activity_api_enabled = false
    end

    it 'doesn\'t display aggregate statistics about user activity' do
      render
      expect(rendered).to_not have_css('.information-board__section')
    end
  end
end
