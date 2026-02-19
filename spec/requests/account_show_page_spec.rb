# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The account show page' do
  it 'has valid opengraph tags' do
    alice = Fabricate(:account, username: 'alice', display_name: 'Alice')
    _status = Fabricate(:status, account: alice, text: 'Hello World')

    get '/@alice'

    expect(head_link_icons.size).to eq(3) # Three favicons with sizes

    expect(head_meta_content('og:title')).to match alice.display_name
    expect(head_meta_content('og:type')).to eq 'profile'
    expect(head_meta_content('og:image')).to match '.+'
    expect(head_meta_content('og:url')).to eq short_account_url(username: alice.username)
  end

  def head_link_icons
    response
      .parsed_body
      .search('html head link[rel=icon]')
  end

  def head_meta_content(property)
    response
      .parsed_body
      .search("html head meta[property='#{property}']")
      .attr('content')
      .text
  end
end
