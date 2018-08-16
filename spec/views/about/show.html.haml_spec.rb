# frozen_string_literal: true

require 'rails_helper'

describe 'about/show.html.haml', without_verify_partial_doubles: true do
  before do
    allow(view).to receive(:site_hostname).and_return('example.com')
    allow(view).to receive(:site_title).and_return('example site')
  end

  it 'has valid open graph tags' do
    instance_presenter = double(:instance_presenter,
                                site_title: 'something',
                                site_short_description: 'something',
                                site_description: 'something',
                                version_number: '1.0',
                                source_url: 'https://github.com/tootsuite/mastodon',
                                open_registrations: false,
                                thumbnail: nil,
                                hero: nil,
                                user_count: 0,
                                status_count: 0,
                                contact_account: nil,
                                closed_registrations_message: 'yes')
    assign(:instance_presenter, instance_presenter)
    render

    header_tags = view.content_for(:header_tags)

    expect(header_tags).to match(%r{<meta content=".+" property="og:title" />})
    expect(header_tags).to match(%r{<meta content="website" property="og:type" />})
    expect(header_tags).to match(%r{<meta content=".+" property="og:image" />})
    expect(header_tags).to match(%r{<meta content="http://.+" property="og:url" />})
  end
end
