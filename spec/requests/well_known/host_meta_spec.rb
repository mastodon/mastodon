# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The /.well-known/host-meta request' do
  it 'returns http success with valid XML response' do
    get '/.well-known/host-meta'

    expect(response)
      .to have_http_status(200)
      .and have_attributes(
        media_type: 'application/xrd+xml'
      )

    doc = Nokogiri::XML(response.parsed_body)
    expect(doc.at_xpath('/xrd:XRD/xrd:Link[@rel="lrdd"]/@template', 'xrd' => 'http://docs.oasis-open.org/ns/xri/xrd-1.0').value)
      .to eq 'https://cb6e6126.ngrok.io/.well-known/webfinger?resource={uri}'
  end

  it 'returns http success with valid JSON response with .json extension' do
    get '/.well-known/host-meta.json'

    expect(response)
      .to have_http_status(200)
      .and have_attributes(
        media_type: 'application/json'
      )

    expect(response.parsed_body)
      .to include(
        links: [
          'rel' => 'lrdd',
          'template' => 'https://cb6e6126.ngrok.io/.well-known/webfinger?resource={uri}',
        ]
      )
  end

  it 'returns http success with valid JSON response with Accept header' do
    get '/.well-known/host-meta', headers: { 'Accept' => 'application/json' }

    expect(response)
      .to have_http_status(200)
      .and have_attributes(
        media_type: 'application/json'
      )
  end
end
