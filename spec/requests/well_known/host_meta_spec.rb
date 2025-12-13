# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The /.well-known/host-meta request' do
  context 'without extension format or accept header' do
    it 'returns http success with expected XML' do
      get '/.well-known/host-meta'

      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          media_type: 'application/xrd+xml'
        )

      expect(xrd_link_template_value)
        .to eq "https://#{Rails.configuration.x.local_domain}/.well-known/webfinger?resource={uri}"
    end

    def xrd_link_template_value
      response
        .parsed_body
        .at_xpath('/xrd:XRD/xrd:Link[@rel="lrdd"]/@template', 'xrd' => 'http://docs.oasis-open.org/ns/xri/xrd-1.0')
        .value
    end
  end

  context 'with a .json format extension' do
    it 'returns http success with expected JSON' do
      get '/.well-known/host-meta.json'

      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          media_type: 'application/json'
        )
      expect(response.parsed_body)
        .to include(expected_json_template)
    end
  end

  context 'with a JSON `Accept` header' do
    it 'returns http success with expected JSON' do
      get '/.well-known/host-meta', headers: { 'Accept' => 'application/json' }

      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          media_type: 'application/json'
        )
      expect(response.parsed_body)
        .to include(expected_json_template)
    end
  end

  def expected_json_template
    {
      links: [
        'rel' => 'lrdd',
        'template' => "https://#{Rails.configuration.x.local_domain}/.well-known/webfinger?resource={uri}",
      ],
    }
  end
end
