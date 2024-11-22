# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'statuses/show.html.haml' do
  let(:alice) { Fabricate(:account, username: 'alice', display_name: 'Alice') }
  let(:status) { Fabricate(:status, account: alice, text: 'Hello World') }

  before do
    view.extend view_helpers

    assign(:instance_presenter, InstancePresenter.new)

    Fabricate(:media_attachment, account: alice, status: status, type: :video)

    assign(:status, status)
    assign(:account, alice)
    assign(:descendant_threads, [])
  end

  it 'has valid opengraph tags and twitter player tags' do
    render

    expect(header_tags)
      .to match(/<meta content=".+" property="og:title">/)
      .and match(/<meta content="article" property="og:type">/)
      .and match(/<meta content=".+" property="og:image">/)
      .and match(%r{<meta content="http://.+" property="og:url">})

    expect(header_tags)
      .to match(%r{<meta content="http://.+/media/.+/player" property="twitter:player">})
      .and match(/<meta content="player" property="twitter:card">/)
  end

  def header_tags
    view.content_for(:header_tags)
  end

  def view_helpers
    Module.new do
      def api_oembed_url(_) = ''
      def show_landing_strip? = true
      def site_title = 'example site'
      def site_hostname = 'example.com'
      def full_asset_url(_) = '//asset.host/image.svg'
      def current_account = nil
      def single_user_mode? = false
      def local_time = nil
      def local_time_ago = nil
    end
  end
end
