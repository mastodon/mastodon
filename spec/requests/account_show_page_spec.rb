# frozen_string_literal: true

require 'rails_helper'

describe 'The account show page' do
  it 'has valid opengraph tags' do
    alice = Fabricate(:account, username: 'alice', display_name: 'Alice')
    _status = Fabricate(:status, account: alice, text: 'Hello World')

    get '/@alice'

    expect(head_link_icons.size).to eq(4) # One general favicon and three with sizes

    expect(head_meta_content('og:title')).to match alice.display_name
    expect(head_meta_content('og:type')).to eq 'profile'
    expect(head_meta_content('og:image')).to match '.+'
    expect(head_meta_content('og:url')).to match 'http://.+'
  end

  def head_link_icons
    head_section.css('link[rel=icon]')
  end

  def head_meta_content(property)
    head_section.meta("[@property='#{property}']")[:content]
  end

  def head_section
    Nokogiri::Slop(response.body).html.head
  end
end
