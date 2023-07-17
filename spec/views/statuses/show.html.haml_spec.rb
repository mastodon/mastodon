# frozen_string_literal: true

require 'rails_helper'

describe 'statuses/show.html.haml', without_verify_partial_doubles: true do
  before do
    allow(view).to receive(:api_oembed_url).and_return('')
    allow(view).to receive(:show_landing_strip?).and_return(true)
    allow(view).to receive(:site_title).and_return('example site')
    allow(view).to receive(:site_hostname).and_return('example.com')
    allow(view).to receive(:full_asset_url).and_return('//asset.host/image.svg')
    allow(view).to receive(:local_time)
    allow(view).to receive(:local_time_ago)
    allow(view).to receive(:current_account).and_return(nil)
    allow(view).to receive(:single_user_mode?).and_return(false)
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
