require 'spec_helper'

RSpec::Matchers.define :fail_with do |message|
  match do |actual|
    actual.redirect? && /\?.*message=#{message}/ === actual.location
  end
end

def post_xml(xml=:example_response, opts = {})
  post "/auth/saml/callback", opts.merge({'SAMLResponse' => load_xml(xml)})
end

describe OmniAuth::Strategies::SAML, :type => :strategy do
  include OmniAuth::Test::StrategyTestCase

  let(:auth_hash){ last_request.env['omniauth.auth'] }
  let(:saml_options) do
    {
      :assertion_consumer_service_url     => "http://localhost:9080/auth/saml/callback",
      :single_logout_service_url          => "http://localhost:9080/auth/saml/slo",
      :idp_sso_target_url                 => "https://idp.sso.example.com/signon/29490",
      :idp_slo_target_url                 => "https://idp.sso.example.com/signoff/29490",
      :idp_cert_fingerprint               => "C1:59:74:2B:E8:0C:6C:A9:41:0F:6E:83:F6:D1:52:25:45:58:89:FB",
      :idp_sso_target_url_runtime_params  => {:original_param_key => :mapped_param_key},
      :name_identifier_format             => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
      :request_attributes                 => [
        { :name => 'email', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Email address' },
        { :name => 'name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Full name' },
        { :name => 'first_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Given name' },
        { :name => 'last_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Family name' }
      ],
      :attribute_service_name             => 'Required attributes'
    }
  end
  let(:strategy) { [OmniAuth::Strategies::SAML, saml_options] }

  describe 'GET /auth/saml' do
    context 'without idp runtime params present' do
      before do
        get '/auth/saml'
      end

      it 'should get authentication page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to match /https:\/\/idp.sso.example.com\/signon\/29490/
        expect(last_response.location).to match /\?SAMLRequest=/
        expect(last_response.location).not_to match /mapped_param_key/
        expect(last_response.location).not_to match /original_param_key/
      end
    end

    context 'with idp runtime params' do
      before do
        get '/auth/saml', 'original_param_key' => 'original_param_value', 'mapped_param_key' => 'mapped_param_value'
      end

      it 'should get authentication page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to match /https:\/\/idp.sso.example.com\/signon\/29490/
        expect(last_response.location).to match /\?SAMLRequest=/
        expect(last_response.location).to match /\&mapped_param_key=original_param_value/
        expect(last_response.location).not_to match /original_param_key/
      end
    end

    context "when the assertion_consumer_service_url is the default" do
      before :each do
        saml_options[:compress_request] = false
        saml_options.delete(:assertion_consumer_service_url)
      end

      it 'should send the current callback_url as the assertion_consumer_service_url' do
        %w(foo.example.com bar.example.com).each do |host|
          get "https://#{host}/auth/saml"

          expect(last_response).to be_redirect

          location = URI.parse(last_response.location)
          query = Rack::Utils.parse_query location.query
          expect(query).to have_key('SAMLRequest')

          request = REXML::Document.new(Base64.decode64(query['SAMLRequest']))
          expect(request.root).not_to be_nil

          acs = request.root.attributes.get_attribute('AssertionConsumerServiceURL')
          expect(acs.to_s).to eq "https://#{host}/auth/saml/callback"
        end
      end
    end

    context 'when authn request signing is requested' do
      subject { get '/auth/saml' }

      let(:private_key) { OpenSSL::PKey::RSA.new 2048 }

      before do
        saml_options[:compress_request] = false

        saml_options[:private_key] = private_key.to_pem
        saml_options[:security] = {
          authn_requests_signed: true,
          signature_method: XMLSecurity::Document::RSA_SHA256
        }
      end

      it 'should sign the request' do
        is_expected.to be_redirect

        location = URI.parse(last_response.location)
        query = Rack::Utils.parse_query location.query
        expect(query).to have_key('SAMLRequest')
        expect(query).to have_key('Signature')
        expect(query).to have_key('SigAlg')

        expect(query['SigAlg']).to eq XMLSecurity::Document::RSA_SHA256
      end
    end
  end

  describe 'POST /auth/saml/callback' do
    subject { last_response }

    let(:xml) { :example_response }

    before :each do
      allow(Time).to receive(:now).and_return(Time.utc(2012, 11, 8, 20, 40, 00))
    end

    context "when the response is valid" do
      before :each do
        post_xml
      end

      it "should set the uid to the nameID in the SAML response" do
        expect(auth_hash['uid']).to eq '_1f6fcf6be5e13b08b1e3610e7ff59f205fbd814f23'
      end

      it "should set the raw info to all attributes" do
        expect(auth_hash['extra']['raw_info'].all.to_hash).to eq(
          'first_name'   => ['Rajiv'],
          'last_name'    => ['Manglani'],
          'email'        => ['user@example.com'],
          'company_name' => ['Example Company'],
          'fingerprint'  => saml_options[:idp_cert_fingerprint]
        )
      end

      it "should set the response_object to the response object from ruby_saml response" do
        expect(auth_hash['extra']['response_object']).to be_kind_of(OneLogin::RubySaml::Response)
      end
    end

    context "when fingerprint is empty and there's a fingerprint validator" do
      before :each do
        saml_options.delete(:idp_cert_fingerprint)
        saml_options[:idp_cert_fingerprint_validator] = fingerprint_validator
      end

      let(:fingerprint_validator) { lambda { |_| "C1:59:74:2B:E8:0C:6C:A9:41:0F:6E:83:F6:D1:52:25:45:58:89:FB" } }

      context "when the fingerprint validator returns a truthy value" do
        before { post_xml }

        it "should set the uid to the nameID in the SAML response" do
          expect(auth_hash['uid']).to eq '_1f6fcf6be5e13b08b1e3610e7ff59f205fbd814f23'
        end

        it "should set the raw info to all attributes" do
          expect(auth_hash['extra']['raw_info'].all.to_hash).to eq(
            'first_name'   => ['Rajiv'],
            'last_name'    => ['Manglani'],
            'email'        => ['user@example.com'],
            'company_name' => ['Example Company'],
            'fingerprint'  => 'C1:59:74:2B:E8:0C:6C:A9:41:0F:6E:83:F6:D1:52:25:45:58:89:FB'
          )
        end
      end

      context "when the fingerprint validator returns false" do
        let(:fingerprint_validator) { lambda { |_| false } }

        before { post_xml }

        it { is_expected.to fail_with(:invalid_ticket) }
      end
    end

    context "when the assertion_consumer_service_url is the default" do
      before :each do
        saml_options.delete(:assertion_consumer_service_url)
        OmniAuth.config.full_host = 'http://localhost:9080'
        post_xml
      end

      it { is_expected.not_to fail_with(:invalid_ticket) }
    end

    context "when there is no SAMLResponse parameter" do
      before :each do
        post '/auth/saml/callback'
      end

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when there is no name id in the XML" do
      before :each do
        allow(Time).to receive(:now).and_return(Time.utc(2012, 11, 8, 23, 55, 00))
        post_xml :no_name_id
      end

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when the fingerprint is invalid" do
      before :each do
        saml_options[:idp_cert_fingerprint] = "00:00:00:00:00:0C:6C:A9:41:0F:6E:83:F6:D1:52:25:45:58:89:FB"
        post_xml
      end

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when the digest is invalid" do
      before :each do
        post_xml :digest_mismatch
      end

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when the signature is invalid" do
      before :each do
        post_xml :invalid_signature
      end

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when the response is stale" do
      before :each do
        allow(Time).to receive(:now).and_return(Time.utc(2012, 11, 8, 20, 45, 00))
      end

      context "without :allowed_clock_drift option" do
        before { post_xml :example_response }

        it { is_expected.to fail_with(:invalid_ticket) }
      end

      context "with :allowed_clock_drift option" do
        before :each do
          saml_options[:allowed_clock_drift] = 60
          post_xml :example_response
        end

        it { is_expected.to_not fail_with(:invalid_ticket) }
      end
    end

    context "when response has custom attributes" do
      before :each do
        saml_options[:idp_cert_fingerprint] = "3B:82:F1:F5:54:FC:A8:FF:12:B8:4B:B8:16:61:1D:E4:8E:9B:E2:3C"
        saml_options[:attribute_statements] = {
          email: ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"],
          first_name: ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"],
          last_name: ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"]
        }
        post_xml :custom_attributes
      end

      it "should obey attribute statements mapping" do
        expect(auth_hash[:info]).to eq(
          'first_name'   => 'Rajiv',
          'last_name'    => 'Manglani',
          'email'        => 'user@example.com',
          'name'         => nil
        )
      end
    end

    context "when using custom user id attribute" do
      before :each do
        saml_options[:idp_cert_fingerprint] = "3B:82:F1:F5:54:FC:A8:FF:12:B8:4B:B8:16:61:1D:E4:8E:9B:E2:3C"
        saml_options[:uid_attribute] = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        post_xml :custom_attributes
      end

      it "should return user id attribute" do
        expect(auth_hash[:uid]).to eq("user@example.com")
      end
    end

    context "when using custom user id attribute, but it is missing" do
      before :each do
        saml_options[:uid_attribute] = "missing_attribute"
        post_xml
      end

      it "should fail to authenticate" do
        should fail_with(:invalid_ticket)
        expect(last_request.env['omniauth.error']).to be_instance_of(OmniAuth::Strategies::SAML::ValidationError)
        expect(last_request.env['omniauth.error'].message).to eq("SAML response missing 'missing_attribute' attribute")
      end
    end

    context "when response is a logout response" do
      before :each do
        saml_options[:issuer] = "https://idp.sso.example.com/metadata/29490"

        post "/auth/saml/slo", {
          SAMLResponse: load_xml(:example_logout_response),
          RelayState: "https://example.com/",
        }, "rack.session" => {"saml_transaction_id" => "_3fef1069-d0c6-418a-b68d-6f008a4787e9"}
      end
      it "should redirect to relaystate" do
        expect(last_response).to be_redirect
        expect(last_response.location).to match /https:\/\/example.com\//
      end
    end

    context "when request is a logout request" do
      subject { post "/auth/saml/slo", params, "rack.session" => { "saml_uid" => "username@example.com" } }

      before :each do
        saml_options[:issuer] = "https://idp.sso.example.com/metadata/29490"
      end

      let(:params) do
        {
          "SAMLRequest" => load_xml(:example_logout_request),
          "RelayState" => "https://example.com/",
        }
      end

      context "when logout request is valid" do
        before { subject }

        it "should redirect to logout response" do
          expect(last_response).to be_redirect
          expect(last_response.location).to match /https:\/\/idp.sso.example.com\/signoff\/29490/
          expect(last_response.location).to match /RelayState=https%3A%2F%2Fexample.com%2F/
        end
      end

      context "when request is an invalid logout request" do
        before :each do
          allow_any_instance_of(OneLogin::RubySaml::SloLogoutrequest).to receive(:is_valid?).and_return(false)
        end

        # TODO: Maybe this should not raise an exception, but return some 4xx error instead?
        it "should raise an exception" do
          expect { subject }.
            to raise_error(OmniAuth::Strategies::SAML::ValidationError, 'SAML failed to process LogoutRequest')
        end
      end

      context "when request is a logout request but the request param is missing" do
        let(:params) { {} }

        # TODO: Maybe this should not raise an exception, but return a 422 error instead?
        it 'should raise an exception' do
          expect { subject }.
            to raise_error(OmniAuth::Strategies::SAML::ValidationError, 'SAML logout response/request missing')
        end
      end
    end

    context "when sp initiated SLO" do
      def test_default_relay_state(static_default_relay_state = nil, &block_default_relay_state)
        saml_options["slo_default_relay_state"] = static_default_relay_state || block_default_relay_state
        post "/auth/saml/spslo"

        expect(last_response).to be_redirect
        expect(last_response.location).to match /https:\/\/idp.sso.example.com\/signoff\/29490/
        expect(last_response.location).to match /RelayState=https%3A%2F%2Fexample.com%2F/
      end

      it "should redirect to logout request" do
        test_default_relay_state("https://example.com/")
      end

      it "should redirect to logout request with a block" do
        test_default_relay_state do
          "https://example.com/"
        end
      end

      it "should redirect to logout request with a block with a request parameter" do
        test_default_relay_state do |request|
          "https://example.com/"
        end
      end

      it "should give not implemented without an idp_slo_target_url" do
        saml_options.delete(:idp_slo_target_url)
        post "/auth/saml/spslo"

        expect(last_response.status).to eq 501
        expect(last_response.body).to match /Not Implemented/
      end
    end
  end

  describe 'GET /auth/saml/metadata' do
    before do
      saml_options[:issuer] = 'http://example.com/SAML'
      get '/auth/saml/metadata'
    end

    it 'should get SP metadata page' do
      expect(last_response.status).to eq 200
      expect(last_response.header["Content-Type"]).to eq "application/xml"
    end

    it 'should configure attributes consuming service' do
      expect(last_response.body).to match /AttributeConsumingService/
      expect(last_response.body).to match /first_name/
      expect(last_response.body).to match /last_name/
      expect(last_response.body).to match /Required attributes/
      expect(last_response.body).to match /entityID/
      expect(last_response.body).to match /http:\/\/example.com\/SAML/
    end
  end

  context 'when hitting an unknown route in our sub path' do
    before { get '/auth/saml/unknown' }

    specify { expect(last_response.status).to eql 404 }
  end

  context 'when hitting a completely unknown route' do
    before { get '/unknown' }

    specify { expect(last_response.status).to eql 404 }
  end

  context 'when hitting a route that contains a substring match for the strategy name' do
    before { get '/auth/saml2/metadata' }

    it 'should not set the strategy' do
      expect(last_request.env['omniauth.strategy']).to be_nil
      expect(last_response.status).to eql 404
    end
  end

  describe 'subclass behavior' do
    it 'registers subclasses in OmniAuth.strategies' do
      subclass = Class.new(described_class)
      expect(OmniAuth.strategies).to include(described_class, subclass)
    end
  end
end
