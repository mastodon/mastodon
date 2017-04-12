require "rails_helper"

describe "The webfinger route" do
  let(:alice) { Fabricate(:account, username: 'alice') }

  describe "requested without accepts headers" do
    it "returns a json response" do
      get webfinger_url, params: { resource: alice.to_webfinger_s }

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq "application/jrd+json"
    end
  end

  describe "requested with html in accepts headers" do
    it "returns a json response" do
      headers = { 'HTTP_ACCEPT' => 'text/html' }
      get webfinger_url, params: { resource: alice.to_webfinger_s }, headers: headers

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq "application/jrd+json"
    end
  end

  describe "requested with xml format" do
    it "returns an xml response" do
      get webfinger_url(resource: alice.to_webfinger_s, format: :xml)

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq "application/xrd+xml"
    end
  end
end
