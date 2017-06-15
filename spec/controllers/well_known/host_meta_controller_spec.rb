require 'rails_helper'

describe WellKnown::HostMetaController, type: :controller do
  render_views

  describe 'GET #show' do
    it 'returns http success' do
      get :show, format: :xml

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq 'application/xrd+xml'
      expect(response.body).to eq <<XML
<?xml version="1.0"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="lrdd" type="application/xrd+xml" template="https://cb6e6126.ngrok.io/.well-known/webfinger?resource={uri}"/>
</XRD>
XML
    end
  end
end
