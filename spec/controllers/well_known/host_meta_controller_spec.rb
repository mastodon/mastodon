# frozen_string_literal: true

require 'rails_helper'

describe WellKnown::HostMetaController, type: :controller do
  render_views

  describe 'GET #show' do
    it 'returns http success' do
      get :show, format: :xml

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/xrd+xml'
      expect(response.body).to eq <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
          <Link rel="lrdd" template="https://cb6e6126.ngrok.io/.well-known/webfinger?resource={uri}"/>
        </XRD>
      XML
    end
  end
end
