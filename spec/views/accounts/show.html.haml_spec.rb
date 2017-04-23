require 'rails_helper'

describe 'accounts/show.html.haml' do
  before do
    allow(view).to receive(:show_landing_strip?).and_return(true)
  end

  it 'has an h-feed with correct number of h-entry objects in it' do
    alice   =  Fabricate(:account, username: 'alice', display_name: 'Alice')
    status  =  Fabricate(:status, account: alice, text: 'Hello World')
    status2 =  Fabricate(:status, account: alice, text: 'Hello World Again')
    status3 =  Fabricate(:status, account: alice, text: 'Are You Still There World?')

    assign(:account, alice)
    assign(:statuses, alice.statuses)
    assign(:stream_entry, status.stream_entry)
    assign(:type, status.stream_entry.activity_type.downcase)

    render

    expect(Nokogiri::HTML(rendered).search('.h-feed .h-entry').size).to eq 3
  end

  it 'has valid opengraph tags' do
    alice   =  Fabricate(:account, username: 'alice', display_name: 'Alice')
    status  =  Fabricate(:status, account: alice, text: 'Hello World')

    assign(:account, alice)
    assign(:statuses, alice.statuses)
    assign(:stream_entry, status.stream_entry)
    assign(:type, status.stream_entry.activity_type.downcase)

    render

    header_tags = view.content_for(:header_tags)

    expect(header_tags).to match(%r{<meta content='.+' property='og:title'>})
    expect(header_tags).to match(%r{<meta content='profile' property='og:type'>})
    expect(header_tags).to match(%r{<meta content='.+' property='og:image'>})
    expect(header_tags).to match(%r{<meta content='http://.+' property='og:url'>})
  end
end
