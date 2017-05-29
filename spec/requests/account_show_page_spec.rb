# frozen_string_literal: true

require 'rails_helper'

describe 'The account show page' do
  it 'Has an h-feed with correct number of h-entry objects in it' do
    alice = Fabricate(:account, username: 'alice', display_name: 'Alice')
    _status = Fabricate(:status, account: alice, text: 'Hello World')
    _status2 = Fabricate(:status, account: alice, text: 'Hello World Again')
    _status3 = Fabricate(:status, account: alice, text: 'Are You Still There World?')

    get '/@alice'

    expect(h_feed_entries.size).to eq(3)
  end

  it 'has valid opengraph tags' do
    alice = Fabricate(:account, username: 'alice', display_name: 'Alice')
    _status = Fabricate(:status, account: alice, text: 'Hello World')

    get '/@alice'

    expect(head_meta_content('og:title')).to match alice.display_name
    expect(head_meta_content('og:type')).to eq 'profile'
    expect(head_meta_content('og:image')).to match '.+'
    expect(head_meta_content('og:url')).to match 'http://.+'
  end

  def head_meta_content(property)
    head_section.meta("[@property='#{property}']")[:content]
  end

  def head_section
    Nokogiri::Slop(response.body).html.head
  end

  def h_feed_entries
    Nokogiri::HTML(response.body).search('.h-feed .h-entry')
  end
end
