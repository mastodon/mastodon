# frozen_string_literal: true

require 'rails_helper'

describe 'about/show.html.haml', without_verify_partial_doubles: true do
  before do
    allow(view).to receive(:site_hostname).and_return('example.com')
    allow(view).to receive(:site_title).and_return('example site')
    allow(view).to receive(:new_user).and_return(User.new)
    allow(view).to receive(:use_seamless_external_login?).and_return(false)
    allow(view).to receive(:current_account).and_return(nil)
  end

  it 'has valid open graph tags' do
    assign(:instance_presenter, InstancePresenter.new)
    render

    header_tags = view.content_for(:header_tags)

    expect(header_tags).to match(%r{<meta content=".+" property="og:title" />})
    expect(header_tags).to match(%r{<meta content="website" property="og:type" />})
    expect(header_tags).to match(%r{<meta content=".+" property="og:image" />})
    expect(header_tags).to match(%r{<meta content="http://.+" property="og:url" />})
  end
end
