# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The /.well-known/host-meta request' do
  it 'returns http success with valid XML response' do
    get '/.well-known/host-meta'

    expect(response)
      .to have_http_status(200)
      .and have_attributes(
        media_type: 'application/xrd+xml',
        body: host_meta_xml_template
      )
  end

  private

  def host_meta_xml_template
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
        <Link rel="lrdd" template="https://cb6e6126.ngrok.io/.well-known/webfinger?resource={uri}"/>
      </XRD>
    XML
  end
end
