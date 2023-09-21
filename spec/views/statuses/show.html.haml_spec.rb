# frozen_string_literal: true

require 'rails_helper'

describe 'statuses/show.html.haml', without_verify_partial_doubles: true do
  before do
    allow(view).to receive_messages(api_oembed_url: '', show_landing_strip?: true, site_title: 'example site', site_hostname: 'example.com', full_asset_url: '//asset.host/image.svg', current_account: nil, single_user_mode?: false)
    allow(view).to receive(:local_time)
    allow(view).to receive(:local_time_ago)
    assign(:instance_presenter, InstancePresenter.new)
  end

  it 'has valid opengraph tags' do
    alice  = Fabricate(:account, username: 'alice', display_name: 'Alice')
    status = Fabricate(:status, account: alice, text: 'Hello World')
    media  = Fabricate(:media_attachment, account: alice, status: status, type: :video)

    assign(:status, status)
    assign(:account, alice)
    assign(:descendant_threads, [])

    render

    header_tags = view.content_for(:header_tags)

    expect(header_tags).to match(/<meta content=".+" property="og:title">/)
    expect(header_tags).to match(/<meta content="article" property="og:type">/)
    expect(header_tags).to match(/<meta content=".+" property="og:image">/)
    expect(header_tags).to match(%r{<meta content="http://.+" property="og:url">})
  end

  it 'has twitter player tag' do
    alice  = Fabricate(:account, username: 'alice', display_name: 'Alice')
    status = Fabricate(:status, account: alice, text: 'Hello World')
    media  = Fabricate(:media_attachment, account: alice, status: status, type: :video)

    assign(:status, status)
    assign(:account, alice)
    assign(:descendant_threads, [])

    render

    header_tags = view.content_for(:header_tags)

    expect(header_tags).to match(%r{<meta content="http://.+/media/.+/player" property="twitter:player">})
    expect(header_tags).to match(/<meta content="player" property="twitter:card">/)
  end
end
