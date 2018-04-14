require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

require 'onelogin/ruby-saml/authrequest'

class RequestTest < Minitest::Test

  describe "Authrequest" do
    let(:settings) { OneLogin::RubySaml::Settings.new }

    before do
      settings.idp_sso_target_url = "http://example.com"
    end

    it "create the deflated SAMLRequest URL parameter" do
      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
      assert_match /^http:\/\/example\.com\?SAMLRequest=/, auth_url
      payload  = CGI.unescape(auth_url.split("=").last)
      decoded  = Base64.decode64(payload)

      zstream  = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      inflated = zstream.inflate(decoded)
      zstream.finish
      zstream.close

      assert_match /^<samlp:AuthnRequest/, inflated
    end

    it "create the deflated SAMLRequest URL parameter including the Destination" do
      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
      payload  = CGI.unescape(auth_url.split("=").last)
      decoded  = Base64.decode64(payload)

      zstream  = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      inflated = zstream.inflate(decoded)
      zstream.finish
      zstream.close

      assert_match /<samlp:AuthnRequest[^<]* Destination='http:\/\/example.com'/, inflated
    end

    it "create the SAMLRequest URL parameter without deflating" do
      settings.compress_request = false
      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
      assert_match /^http:\/\/example\.com\?SAMLRequest=/, auth_url
      payload  = CGI.unescape(auth_url.split("=").last)
      decoded  = Base64.decode64(payload)

      assert_match /^<samlp:AuthnRequest/, decoded
    end

    it "create the SAMLRequest URL parameter with IsPassive" do
      settings.passive = true
      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
      assert_match /^http:\/\/example\.com\?SAMLRequest=/, auth_url
      payload  = CGI.unescape(auth_url.split("=").last)
      decoded  = Base64.decode64(payload)

      zstream  = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      inflated = zstream.inflate(decoded)
      zstream.finish
      zstream.close

      assert_match /<samlp:AuthnRequest[^<]* IsPassive='true'/, inflated
    end

    it "create the SAMLRequest URL parameter with ProtocolBinding" do
      settings.protocol_binding = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'
      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
      assert_match /^http:\/\/example\.com\?SAMLRequest=/, auth_url
      payload  = CGI.unescape(auth_url.split("=").last)
      decoded  = Base64.decode64(payload)

      zstream  = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      inflated = zstream.inflate(decoded)
      zstream.finish
      zstream.close

      assert_match /<samlp:AuthnRequest[^<]* ProtocolBinding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'/, inflated
    end

    it "create the SAMLRequest URL parameter with AttributeConsumingServiceIndex" do
      settings.attributes_index = 30
      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
      assert_match /^http:\/\/example\.com\?SAMLRequest=/, auth_url
      payload  = CGI.unescape(auth_url.split("=").last)
      decoded  = Base64.decode64(payload)

      zstream  = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      inflated = zstream.inflate(decoded)
      zstream.finish
      zstream.close
      assert_match /<samlp:AuthnRequest[^<]* AttributeConsumingServiceIndex='30'/, inflated
    end

    it "create the SAMLRequest URL parameter with ForceAuthn" do
      settings.force_authn = true
      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
      assert_match /^http:\/\/example\.com\?SAMLRequest=/, auth_url
      payload  = CGI.unescape(auth_url.split("=").last)
      decoded  = Base64.decode64(payload)

      zstream  = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      inflated = zstream.inflate(decoded)
      zstream.finish
      zstream.close
      assert_match /<samlp:AuthnRequest[^<]* ForceAuthn='true'/, inflated
    end

    it "create the SAMLRequest URL parameter with NameID Format" do
      settings.name_identifier_format = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
      assert_match /^http:\/\/example\.com\?SAMLRequest=/, auth_url
      payload = CGI.unescape(auth_url.split("=").last)
      decoded = Base64.decode64(payload)
      zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      inflated = zstream.inflate(decoded)
      zstream.finish
      zstream.close

      assert_match /<samlp:NameIDPolicy[^<]* AllowCreate='true'/, inflated
      assert_match /<samlp:NameIDPolicy[^<]* Format='urn:oasis:names:tc:SAML:2.0:nameid-format:transient'/, inflated
    end

    it "accept extra parameters" do
      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings, { :hello => "there" })
      assert_match /&hello=there$/, auth_url

      auth_url = OneLogin::RubySaml::Authrequest.new.create(settings, { :hello => nil })
      assert_match /&hello=$/, auth_url
    end

    describe "when the target url doesn't contain a query string" do
      it "create the SAMLRequest parameter correctly" do

        auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
        assert_match /^http:\/\/example.com\?SAMLRequest/, auth_url
      end
    end

    describe "when the target url contains a query string" do
      it "create the SAMLRequest parameter correctly" do
        settings.idp_sso_target_url = "http://example.com?field=value"

        auth_url = OneLogin::RubySaml::Authrequest.new.create(settings)
        assert_match /^http:\/\/example.com\?field=value&SAMLRequest/, auth_url
      end
    end

    it "create the saml:AuthnContextClassRef element correctly" do
      settings.authn_context = 'secure/name/password/uri'
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert_match /<saml:AuthnContextClassRef>secure\/name\/password\/uri<\/saml:AuthnContextClassRef>/, auth_doc.to_s
    end

    it "create multiple saml:AuthnContextClassRef elements correctly" do
      settings.authn_context = ['secure/name/password/uri', 'secure/email/password/uri']
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert_match /<saml:AuthnContextClassRef>secure\/name\/password\/uri<\/saml:AuthnContextClassRef>/, auth_doc.to_s
      assert_match /<saml:AuthnContextClassRef>secure\/email\/password\/uri<\/saml:AuthnContextClassRef>/, auth_doc.to_s
    end

    it "create the saml:AuthnContextClassRef with comparison exact" do
      settings.authn_context = 'secure/name/password/uri'
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert_match /<samlp:RequestedAuthnContext[\S ]+Comparison='exact'/, auth_doc.to_s
      assert_match /<saml:AuthnContextClassRef>secure\/name\/password\/uri<\/saml:AuthnContextClassRef>/, auth_doc.to_s
    end

    it "create the saml:AuthnContextClassRef with comparison minimun" do
      settings.authn_context = 'secure/name/password/uri'
      settings.authn_context_comparison = 'minimun'
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert_match /<samlp:RequestedAuthnContext[\S ]+Comparison='minimun'/, auth_doc.to_s
      assert_match /<saml:AuthnContextClassRef>secure\/name\/password\/uri<\/saml:AuthnContextClassRef>/, auth_doc.to_s
    end

    it "create the saml:AuthnContextDeclRef element correctly" do
      settings.authn_context_decl_ref = 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport'
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert_match /<saml:AuthnContextDeclRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport<\/saml:AuthnContextDeclRef>/, auth_doc.to_s
    end

    describe "#create_params when the settings indicate to sign (embebed) the request" do
      before do
        settings.compress_request = false
        settings.idp_sso_target_url = "http://example.com?field=value"
        settings.security[:authn_requests_signed] = true
        settings.security[:embed_sign] = true
        settings.certificate = ruby_saml_cert_text
        settings.private_key = ruby_saml_key_text
      end

      it "create a signed request" do
        params = OneLogin::RubySaml::Authrequest.new.create_params(settings)
        request_xml = Base64.decode64(params["SAMLRequest"])
        assert_match %r[<ds:SignatureValue>([a-zA-Z0-9/+=]+)</ds:SignatureValue>], request_xml
        assert_match %r[<ds:SignatureMethod Algorithm='http://www.w3.org/2000/09/xmldsig#rsa-sha1'/>], request_xml
      end

      it "create a signed request with 256 digest and signature methods" do
        settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256
        settings.security[:digest_method] = XMLSecurity::Document::SHA512

        params = OneLogin::RubySaml::Authrequest.new.create_params(settings)

        request_xml = Base64.decode64(params["SAMLRequest"])
        assert_match %r[<ds:SignatureValue>([a-zA-Z0-9/+=]+)</ds:SignatureValue>], request_xml
        assert_match %r[<ds:SignatureMethod Algorithm='http://www.w3.org/2001/04/xmldsig-more#rsa-sha256'/>], request_xml
        assert_match %r[<ds:DigestMethod Algorithm='http://www.w3.org/2001/04/xmlenc#sha512'/>], request_xml
      end
    end

    describe "#create_params when the settings indicate to sign the request" do
      let(:cert) { OpenSSL::X509::Certificate.new(ruby_saml_cert_text) }

      before do
        settings.compress_request = false
        settings.idp_sso_target_url = "http://example.com?field=value"
        settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign"
        settings.security[:authn_requests_signed] = true
        settings.security[:embed_sign] = false
        settings.certificate = ruby_saml_cert_text
        settings.private_key = ruby_saml_key_text
      end
      
      it "create a signature parameter with RSA_SHA1 and validate it" do
        settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1

        params = OneLogin::RubySaml::Authrequest.new.create_params(settings, :RelayState => 'http://example.com')
        assert params['SAMLRequest']
        assert params[:RelayState]
        assert params['Signature']
        assert_equal params['SigAlg'], XMLSecurity::Document::RSA_SHA1

        query_string = "SAMLRequest=#{CGI.escape(params['SAMLRequest'])}"
        query_string << "&RelayState=#{CGI.escape(params[:RelayState])}"
        query_string << "&SigAlg=#{CGI.escape(params['SigAlg'])}"

        signature_algorithm = XMLSecurity::BaseDocument.new.algorithm(params['SigAlg'])
        assert_equal signature_algorithm, OpenSSL::Digest::SHA1

        assert cert.public_key.verify(signature_algorithm.new, Base64.decode64(params['Signature']), query_string)
      end

      it "create a signature parameter with RSA_SHA256 and validate it" do
        settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256

        params = OneLogin::RubySaml::Authrequest.new.create_params(settings, :RelayState => 'http://example.com')
        assert params['Signature']
        assert_equal params['SigAlg'], XMLSecurity::Document::RSA_SHA256

        query_string = "SAMLRequest=#{CGI.escape(params['SAMLRequest'])}"
        query_string << "&RelayState=#{CGI.escape(params[:RelayState])}"
        query_string << "&SigAlg=#{CGI.escape(params['SigAlg'])}"

        signature_algorithm = XMLSecurity::BaseDocument.new.algorithm(params['SigAlg'])
        assert_equal signature_algorithm, OpenSSL::Digest::SHA256
        assert cert.public_key.verify(signature_algorithm.new, Base64.decode64(params['Signature']), query_string)        
      end
    end

    it "create the saml:AuthnContextClassRef element correctly" do
      settings.authn_context = 'secure/name/password/uri'
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert auth_doc.to_s =~ /<saml:AuthnContextClassRef>secure\/name\/password\/uri<\/saml:AuthnContextClassRef>/
    end

    it "create the saml:AuthnContextClassRef with comparison exact" do
      settings.authn_context = 'secure/name/password/uri'
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert auth_doc.to_s =~ /<samlp:RequestedAuthnContext[\S ]+Comparison='exact'/
      assert auth_doc.to_s =~ /<saml:AuthnContextClassRef>secure\/name\/password\/uri<\/saml:AuthnContextClassRef>/
    end

    it "create the saml:AuthnContextClassRef with comparison minimun" do
      settings.authn_context = 'secure/name/password/uri'
      settings.authn_context_comparison = 'minimun'
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert auth_doc.to_s =~ /<samlp:RequestedAuthnContext[\S ]+Comparison='minimun'/
      assert auth_doc.to_s =~ /<saml:AuthnContextClassRef>secure\/name\/password\/uri<\/saml:AuthnContextClassRef>/
    end

    it "create the saml:AuthnContextDeclRef element correctly" do
      settings.authn_context_decl_ref = 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport'
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert auth_doc.to_s =~ /<saml:AuthnContextDeclRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport<\/saml:AuthnContextDeclRef>/
    end

    it "create multiple saml:AuthnContextDeclRef elements correctly " do
      settings.authn_context_decl_ref = ['name/password/uri', 'example/decl/ref']
      auth_doc = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
      assert auth_doc.to_s =~ /<saml:AuthnContextDeclRef>name\/password\/uri<\/saml:AuthnContextDeclRef>/
      assert auth_doc.to_s =~ /<saml:AuthnContextDeclRef>example\/decl\/ref<\/saml:AuthnContextDeclRef>/
    end
  end
end
