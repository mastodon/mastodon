require 'rails_helper'

describe WellKnown::WebfingerController, type: :controller do
  render_views

  describe 'GET #show' do
    let(:alice) do
      Fabricate(:account, username: 'alice')
    end

    before do
      alice.private_key = <<-PEM
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDHgPoPJlrfMZrVcuF39UbVssa8r4ObLP3dYl9Y17Mgp5K4mSYD
R/Y2ag58tSi6ar2zM3Ze3QYsNfTq0NqN1g89eAu0MbSjWqpOsgntRPJiFuj3hai2
X2Im8TBrkiM/UyfTRgn8q8WvMoKbXk8Lu6nqv420eyqhhLxfUoCpxuem1QIDAQAB
AoGBAIKsOh2eM7spVI8mdgQKheEG/iEsnPkQ2R8ehfE9JzjmSbXbqghQJDaz9NU+
G3Uu4R31QT0VbCudE9SSA/UPFl82GeQG4QLjrSE+PSjSkuslgSXelJHfAJ+ycGax
ajtPyiQD0e4c2loagHNHPjqK9OhHx9mFnZWmoagjlZ+mQGEpAkEA8GtqfS65IaRQ
uVhMzpp25rF1RWOwaaa+vBPkd7pGdJEQGFWkaR/a9UkU+2C4ZxGBkJDP9FApKVQI
RANEwN3/hwJBANRuw5+es6BgBv4PD387IJvuruW2oUtYP+Lb2Z5k77J13hZTr0db
Oo9j1UbbR0/4g+vAcsDl4JD9c/9LrGYEpcMCQBon9Yvs+2M3lziy7JhFoc3zXIjS
Ea1M4M9hcqe78lJYPeIH3z04o/+vlcLLgQRlmSz7NESmO/QtGkEcAezhuh0CQHji
pzO4LeO/gXslut3eGcpiYuiZquOjToecMBRwv+5AIKd367Che4uJdh6iPcyGURvh
IewfZFFdyZqnx20ui90CQQC1W2rK5Y30wAunOtSLVA30TLK/tKrTppMC3corjKlB
FTX8IvYBNTbpEttc1VCf/0ccnNpfb0CrFNSPWxRj7t7D
-----END RSA PRIVATE KEY-----
PEM

      alice.public_key = <<-PEM
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHgPoPJlrfMZrVcuF39UbVssa8
r4ObLP3dYl9Y17Mgp5K4mSYDR/Y2ag58tSi6ar2zM3Ze3QYsNfTq0NqN1g89eAu0
MbSjWqpOsgntRPJiFuj3hai2X2Im8TBrkiM/UyfTRgn8q8WvMoKbXk8Lu6nqv420
eyqhhLxfUoCpxuem1QIDAQAB
-----END PUBLIC KEY-----
PEM

      alice.save!
    end

    around(:each) do |example|
      before = Rails.configuration.x.alternate_domains
      example.run
      Rails.configuration.x.alternate_domains = before
    end

    it 'returns JSON when account can be found' do
      get :show, params: { resource: alice.to_webfinger_s }, format: :json

      json = body_as_json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq 'application/jrd+json'
      expect(json[:subject]).to eq 'acct:alice@cb6e6126.ngrok.io'
      expect(json[:aliases]).to include('https://cb6e6126.ngrok.io/@alice', 'https://cb6e6126.ngrok.io/users/alice')
    end

    it 'returns JSON when account can be found' do
      get :show, params: { resource: alice.to_webfinger_s }, format: :xml

      xml = Nokogiri::XML(response.body)

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq 'application/xrd+xml'
      expect(xml.at_xpath('//xmlns:Subject').content).to eq 'acct:alice@cb6e6126.ngrok.io'
      expect(xml.xpath('//xmlns:Alias').map(&:content)).to include('https://cb6e6126.ngrok.io/@alice', 'https://cb6e6126.ngrok.io/users/alice')
    end

    it 'returns http not found when account cannot be found' do
      get :show, params: { resource: 'acct:not@existing.com' }, format: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'returns JSON when account can be found with alternate domains' do
      Rails.configuration.x.alternate_domains = ['foo.org']
      username, = alice.to_webfinger_s.split('@')

      get :show, params: { resource: "#{username}@foo.org" }, format: :json

      json = body_as_json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq 'application/jrd+json'
      expect(json[:subject]).to eq 'acct:alice@cb6e6126.ngrok.io'
      expect(json[:aliases]).to include('https://cb6e6126.ngrok.io/@alice', 'https://cb6e6126.ngrok.io/users/alice')
    end

    it 'returns http not found when account can not be found with alternate domains' do
      Rails.configuration.x.alternate_domains = ['foo.org']
      username, = alice.to_webfinger_s.split('@')

      get :show, params: { resource: "#{username}@bar.org" }, format: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
