require 'rails_helper'
$LOAD_PATH << '../lib'
require 'tag_manager'

describe 'about/show.html.haml' do
  before do
  end

  it 'has valid open graph tags' do
    site_presenter = double(:site_presenter,
				site_description: 'something',
				open_registrations: false,
				closed_registrations_message: 'yes',
			       )
    assign(:site, site_presenter)
    render

    header_tags = view.content_for(:header_tags)

    expect(header_tags).to match(%r{<meta content='.+' property='og:title'>})
    expect(header_tags).to match(%r{<meta content='website' property='og:type'>})
    expect(header_tags).to match(%r{<meta content='.+' property='og:image'>})
    expect(header_tags).to match(%r{<meta content='http://.+' property='og:url'>})
  end
end
