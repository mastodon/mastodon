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
end
