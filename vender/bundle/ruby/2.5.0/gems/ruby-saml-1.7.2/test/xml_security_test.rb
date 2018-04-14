require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))
require 'xml_security'

class XmlSecurityTest < Minitest::Test
  include XMLSecurity

  describe "XmlSecurity" do

    let(:decoded_response) { Base64.decode64(response_document_without_recipient) }
    let(:document) { XMLSecurity::SignedDocument.new(decoded_response) }
    let(:settings) { OneLogin::RubySaml::Settings.new() }

    before do
      @base64cert = document.elements["//ds:X509Certificate"].text
    end

    it "should run validate without throwing NS related exceptions" do
      assert !document.validate_signature(@base64cert, true)
    end

    it "should run validate with throwing NS related exceptions" do
      assert_raises(OneLogin::RubySaml::ValidationError) do
        document.validate_signature(@base64cert, false)
      end
    end

    it "not raise an error when softly validating the document multiple times" do
      2.times { assert_equal document.validate_signature(@base64cert, true), false }
    end

    it "not raise an error when softly validating the document and the X509Certificate is missing" do
      decoded_response.sub!(/<ds:X509Certificate>.*<\/ds:X509Certificate>/, "")
      mod_document = XMLSecurity::SignedDocument.new(decoded_response)
      assert !mod_document.validate_document("a fingerprint", true) # The fingerprint isn't relevant to this test
    end

    it "should raise Fingerprint mismatch" do
      exception = assert_raises(OneLogin::RubySaml::ValidationError) do
        document.validate_document("no:fi:ng:er:pr:in:t", false)
      end
      assert_equal("Fingerprint mismatch", exception.message)
      assert_includes document.errors, "Fingerprint mismatch"
    end

    it "should raise Digest mismatch" do
      exception = assert_raises(OneLogin::RubySaml::ValidationError) do
        document.validate_signature(@base64cert, false)
      end
      assert_equal("Digest mismatch", exception.message)
      assert_includes document.errors, "Digest mismatch"
    end

    it "should raise Key validation error" do
      decoded_response.sub!("<ds:DigestValue>pJQ7MS/ek4KRRWGmv/H43ReHYMs=</ds:DigestValue>",
                    "<ds:DigestValue>b9xsAXLsynugg3Wc1CI3kpWku+0=</ds:DigestValue>")
      mod_document = XMLSecurity::SignedDocument.new(decoded_response)
      base64cert = mod_document.elements["//ds:X509Certificate"].text
      exception = assert_raises(OneLogin::RubySaml::ValidationError) do
        mod_document.validate_signature(base64cert, false)
      end
      assert_equal("Key validation error", exception.message)
      assert_includes mod_document.errors, "Key validation error"
    end

    it "correctly obtain the digest method with alternate namespace declaration" do
      adfs_document = XMLSecurity::SignedDocument.new(fixture(:adfs_response_xmlns, false))
      base64cert = adfs_document.elements["//X509Certificate"].text
      assert adfs_document.validate_signature(base64cert, false)
    end

    it "raise validation error when the X509Certificate is missing and no cert provided" do
      decoded_response.sub!(/<ds:X509Certificate>.*<\/ds:X509Certificate>/, "")
      mod_document = XMLSecurity::SignedDocument.new(decoded_response)
      exception = assert_raises(OneLogin::RubySaml::ValidationError) do
        mod_document.validate_document("a fingerprint", false) # The fingerprint isn't relevant to this test
      end
      assert_equal("Certificate element missing in response (ds:X509Certificate) and not cert provided at settings", exception.message)
    end

    it "invalidaties when the X509Certificate is missing and the cert is provided but mismatches" do
      decoded_response.sub!(/<ds:X509Certificate>.*<\/ds:X509Certificate>/, "")
      mod_document = XMLSecurity::SignedDocument.new(decoded_response)
      cert = OpenSSL::X509::Certificate.new(ruby_saml_cert)
      assert !mod_document.validate_document("a fingerprint", true, :cert => cert) # The fingerprint isn't relevant to this test
    end
  end

  describe "#canon_algorithm" do
    it "C14N_EXCLUSIVE_1_0" do
      canon_algorithm = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0
      assert_equal canon_algorithm, XMLSecurity::BaseDocument.new.canon_algorithm("http://www.w3.org/2001/10/xml-exc-c14n#")
      assert_equal canon_algorithm, XMLSecurity::BaseDocument.new.canon_algorithm("http://www.w3.org/2001/10/xml-exc-c14n#WithComments")
      assert_equal canon_algorithm, XMLSecurity::BaseDocument.new.canon_algorithm("other")
    end

    it "C14N_1_0" do
      canon_algorithm = Nokogiri::XML::XML_C14N_1_0
      assert_equal canon_algorithm, XMLSecurity::BaseDocument.new.canon_algorithm("http://www.w3.org/TR/2001/REC-xml-c14n-20010315")
      assert_equal canon_algorithm, XMLSecurity::BaseDocument.new.canon_algorithm("http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments")
    end

    it "XML_C14N_1_1" do
      canon_algorithm = Nokogiri::XML::XML_C14N_1_1
      assert_equal canon_algorithm, XMLSecurity::BaseDocument.new.canon_algorithm("http://www.w3.org/2006/12/xml-c14n11")
      assert_equal canon_algorithm, XMLSecurity::BaseDocument.new.canon_algorithm("http://www.w3.org/2006/12/xml-c14n11#WithComments")
    end
  end

  describe "#algorithm" do
    it "SHA1" do
      alg = OpenSSL::Digest::SHA1
      assert_equal alg, XMLSecurity::BaseDocument.new.algorithm("http://www.w3.org/2000/09/xmldsig#rsa-sha1")
      assert_equal alg, XMLSecurity::BaseDocument.new.algorithm("http://www.w3.org/2000/09/xmldsig#sha1")
      assert_equal alg, XMLSecurity::BaseDocument.new.algorithm("other")
    end

    it "SHA256" do
      alg = OpenSSL::Digest::SHA256
      assert_equal alg, XMLSecurity::BaseDocument.new.algorithm("http://www.w3.org/2001/04/xmldsig-more#rsa-sha256")
      assert_equal alg, XMLSecurity::BaseDocument.new.algorithm("http://www.w3.org/2001/04/xmldsig-more#sha256")
    end

    it "SHA384" do
      alg = OpenSSL::Digest::SHA384
      assert_equal alg, XMLSecurity::BaseDocument.new.algorithm("http://www.w3.org/2001/04/xmldsig-more#rsa-sha384")
      assert_equal alg, XMLSecurity::BaseDocument.new.algorithm("http://www.w3.org/2001/04/xmldsig-more#sha384")
    end

    it "SHA512" do
      alg = OpenSSL::Digest::SHA512
      assert_equal alg, XMLSecurity::BaseDocument.new.algorithm("http://www.w3.org/2001/04/xmldsig-more#rsa-sha512")
      assert_equal alg, XMLSecurity::BaseDocument.new.algorithm("http://www.w3.org/2001/04/xmldsig-more#sha512")
    end
  end

  describe "Fingerprint Algorithms" do
    let(:response_fingerprint_test) { OneLogin::RubySaml::Response.new(fixture(:adfs_response_sha1, false)) }

    it "validate using SHA1" do
      sha1_fingerprint = "F1:3C:6B:80:90:5A:03:0E:6C:91:3E:5D:15:FA:DD:B0:16:45:48:72"
      sha1_fingerprint_downcase = "f13c6b80905a030e6c913e5d15faddb016454872"

      assert response_fingerprint_test.document.validate_document(sha1_fingerprint)
      assert response_fingerprint_test.document.validate_document(sha1_fingerprint, true, :fingerprint_alg => XMLSecurity::Document::SHA1)

      assert response_fingerprint_test.document.validate_document(sha1_fingerprint_downcase)
      assert response_fingerprint_test.document.validate_document(sha1_fingerprint_downcase, true, :fingerprint_alg => XMLSecurity::Document::SHA1)
    end

    it "validate using SHA256" do
      sha256_fingerprint = "C4:C6:BD:41:EC:AD:57:97:CE:7B:7D:80:06:C3:E4:30:53:29:02:0B:DD:2D:47:02:9E:BD:85:AD:93:02:45:21"

      assert !response_fingerprint_test.document.validate_document(sha256_fingerprint)
      assert response_fingerprint_test.document.validate_document(sha256_fingerprint, true, :fingerprint_alg => XMLSecurity::Document::SHA256)
    end

    it "validate using SHA384" do
      sha384_fingerprint = "98:FE:17:90:31:E7:68:18:8A:65:4D:DA:F5:76:E2:09:97:BE:8B:E3:7E:AA:8D:63:64:7C:0C:38:23:9A:AC:A2:EC:CE:48:A6:74:4D:E0:4C:50:80:40:B4:8D:55:14:14"

      assert !response_fingerprint_test.document.validate_document(sha384_fingerprint)
      assert response_fingerprint_test.document.validate_document(sha384_fingerprint, true, :fingerprint_alg => XMLSecurity::Document::SHA384)
    end

    it "validate using SHA512" do
      sha512_fingerprint = "5A:AE:BA:D0:BA:9D:1E:25:05:01:1E:1A:C9:E9:FF:DB:ED:FA:6E:F7:52:EB:45:49:BD:DB:06:D8:A3:7E:CC:63:3A:04:A2:DD:DF:EE:61:05:D9:58:95:2A:77:17:30:4B:EB:4A:9F:48:4A:44:1C:D0:9E:0B:1E:04:77:FD:A3:D2"

      assert !response_fingerprint_test.document.validate_document(sha512_fingerprint)
      assert response_fingerprint_test.document.validate_document(sha512_fingerprint, true, :fingerprint_alg => XMLSecurity::Document::SHA512)
    end

  end

  describe "Signature Algorithms" do
    it "validate using SHA1" do
      document = XMLSecurity::SignedDocument.new(fixture(:adfs_response_sha1, false))
      assert document.validate_document("F1:3C:6B:80:90:5A:03:0E:6C:91:3E:5D:15:FA:DD:B0:16:45:48:72")
    end

    it "validate using SHA256" do
      document = XMLSecurity::SignedDocument.new(fixture(:adfs_response_sha256, false))
      assert document.validate_document("28:74:9B:E8:1F:E8:10:9C:A8:7C:A9:C3:E3:C5:01:6C:92:1C:B4:BA")
    end

    it "validate using SHA384" do
      document = XMLSecurity::SignedDocument.new(fixture(:adfs_response_sha384, false))
      assert document.validate_document("F1:3C:6B:80:90:5A:03:0E:6C:91:3E:5D:15:FA:DD:B0:16:45:48:72")
    end

    it "validate using SHA512" do
      document = XMLSecurity::SignedDocument.new(fixture(:adfs_response_sha512, false))
      assert document.validate_document("F1:3C:6B:80:90:5A:03:0E:6C:91:3E:5D:15:FA:DD:B0:16:45:48:72")
    end
  end

  describe "XmlSecurity::SignedDocument" do

    describe "#extract_inclusive_namespaces" do
      it "support explicit namespace resolution for exclusive canonicalization" do
        response = fixture(:open_saml_response, false)
        document = XMLSecurity::SignedDocument.new(response)
        inclusive_namespaces = document.send(:extract_inclusive_namespaces)

        assert_equal %w[ xs ], inclusive_namespaces
      end

      it "support implicit namespace resolution for exclusive canonicalization" do
        response = fixture(:no_signature_ns, false)
        document = XMLSecurity::SignedDocument.new(response)
        inclusive_namespaces = document.send(:extract_inclusive_namespaces)

        assert_equal %w[ #default saml ds xs xsi ], inclusive_namespaces
      end

      it 'support inclusive canonicalization' do
        skip('test not yet implemented')
        response = OneLogin::RubySaml::Response.new(fixture("tdnf_response.xml"))
        response.stubs(:conditions).returns(nil)
        assert !response.is_valid?
        assert !response.is_valid?
        response.settings = settings
        assert !response.is_valid?
        settings.idp_cert_fingerprint = "e6 38 9a 20 b7 4f 13 db 6a bc b1 42 6a e7 52 1d d6 56 d4 1b".upcase.gsub(" ", ":")
        assert response.is_valid?
      end

      it "return nil when inclusive namespace element is missing" do
        response = fixture(:no_signature_ns, false)
        response.slice! %r{<InclusiveNamespaces xmlns="http://www.w3.org/2001/10/xml-exc-c14n#" PrefixList="#default saml ds xs xsi"/>}

        document = XMLSecurity::SignedDocument.new(response)
        inclusive_namespaces = document.send(:extract_inclusive_namespaces)

        assert inclusive_namespaces.nil?
      end
    end

    describe "XMLSecurity::DSIG" do
      before do
        settings.idp_sso_target_url = "https://idp.example.com/sso"
        settings.protocol_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
        settings.idp_slo_target_url = "https://idp.example.com/slo",
        settings.issuer = "https://sp.example.com/saml2"
        settings.assertion_consumer_service_url = "https://sp.example.com/acs"
        settings.single_logout_service_url = "https://sp.example.com/sls"
      end

      it "sign an AuthNRequest" do
        request = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
        request.sign_document(ruby_saml_key, ruby_saml_cert)
        # verify our signature
        signed_doc = XMLSecurity::SignedDocument.new(request.to_s)
        assert signed_doc.validate_document(ruby_saml_cert_fingerprint, false)

        request2 = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
        request2.sign_document(ruby_saml_key, ruby_saml_cert_text)
        # verify our signature
        signed_doc2 = XMLSecurity::SignedDocument.new(request2.to_s)
        assert signed_doc2.validate_document(ruby_saml_cert_fingerprint, false)
      end

      it "sign an AuthNRequest with certificate as text" do
        request = OneLogin::RubySaml::Authrequest.new.create_authentication_xml_doc(settings)
        request.sign_document(ruby_saml_key, ruby_saml_cert_text)

        # verify our signature
        signed_doc = XMLSecurity::SignedDocument.new(request.to_s)
        assert signed_doc.validate_document(ruby_saml_cert_fingerprint, false)
      end

      it "sign a LogoutRequest" do
        logout_request = OneLogin::RubySaml::Logoutrequest.new.create_logout_request_xml_doc(settings)
        logout_request.sign_document(ruby_saml_key, ruby_saml_cert)
        # verify our signature
        signed_doc = XMLSecurity::SignedDocument.new(logout_request.to_s)
        assert signed_doc.validate_document(ruby_saml_cert_fingerprint, false)

        logout_request2 = OneLogin::RubySaml::Logoutrequest.new.create_logout_request_xml_doc(settings)
        logout_request2.sign_document(ruby_saml_key, ruby_saml_cert_text)
        # verify our signature
        signed_doc2 = XMLSecurity::SignedDocument.new(logout_request2.to_s)
        signed_doc2.validate_document(ruby_saml_cert_fingerprint, false)
        assert signed_doc2.validate_document(ruby_saml_cert_fingerprint, false)
      end

      it "sign a LogoutResponse" do
        logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create_logout_response_xml_doc(settings, 'request_id_example', "Custom Logout Message")
        logout_response.sign_document(ruby_saml_key, ruby_saml_cert)
        # verify our signature
        signed_doc = XMLSecurity::SignedDocument.new(logout_response.to_s)
        assert signed_doc.validate_document(ruby_saml_cert_fingerprint, false)

        logout_response2 = OneLogin::RubySaml::SloLogoutresponse.new.create_logout_response_xml_doc(settings, 'request_id_example', "Custom Logout Message")
        logout_response2.sign_document(ruby_saml_key, ruby_saml_cert_text)
        # verify our signature
        signed_doc2 = XMLSecurity::SignedDocument.new(logout_response2.to_s)
        signed_doc2.validate_document(ruby_saml_cert_fingerprint, false)
        assert signed_doc2.validate_document(ruby_saml_cert_fingerprint, false)
      end
    end

    describe "StarfieldTMS" do
      let (:response) { OneLogin::RubySaml::Response.new(fixture(:starfield_response)) }

      before do
        response.settings = OneLogin::RubySaml::Settings.new( :idp_cert_fingerprint => "8D:BA:53:8E:A3:B6:F9:F1:69:6C:BB:D9:D8:BD:41:B3:AC:4F:9D:4D")
      end

      it "be able to validate a good response" do
        Timecop.freeze Time.parse('2012-11-28 17:55:00 UTC') do
          response.stubs(:validate_subject_confirmation).returns(true)
          assert response.is_valid?
        end
      end

      it "fail before response is valid" do
        Timecop.freeze Time.parse('2012-11-20 17:55:00 UTC') do
          assert !response.is_valid?

          time_1 = '2012-11-20 17:55:00 UTC < 2012-11-28 17:53:45 UTC'
          time_2 = 'Tue Nov 20 17:55:00 UTC 2012 < Wed Nov 28 17:53:45 UTC 2012'

          errors = [time_1, time_2].map do |time|
            "Current time is earlier than NotBefore condition (#{time})"
          end

          assert_predicate response.errors & errors, :any?
        end
      end

      it "fail after response expires" do
        Timecop.freeze Time.parse('2012-11-30 17:55:00 UTC') do
          assert !response.is_valid?

          contains_expected_error = response.errors.include? "Current time is on or after NotOnOrAfter condition (2012-11-30 17:55:00 UTC >= 2012-11-28 18:33:45 UTC)"
          contains_expected_error ||= response.errors.include? "Current time is on or after NotOnOrAfter condition (Fri Nov 30 17:55:00 UTC 2012 >= Wed Nov 28 18:33:45 UTC 2012)"
          assert contains_expected_error
        end
      end
    end

    describe '#validate_document' do
      describe 'with valid document' do
        describe 'when response has signed message and assertion' do
          let(:document_data) { read_response('response_with_signed_message_and_assertion.xml') }
          let(:document) { OneLogin::RubySaml::Response.new(document_data).document }
          let(:fingerprint) { '4b68c453c7d994aad9025c99d5efcf566287fe8d' }

          it 'is valid' do
            assert document.validate_document(fingerprint, true), 'Document should be valid'
          end
        end

        describe 'when response has signed assertion' do
          let(:document_data) { read_response('response_with_signed_assertion_3.xml') }
          let(:document) { OneLogin::RubySaml::Response.new(document_data).document }
          let(:fingerprint) { '4b68c453c7d994aad9025c99d5efcf566287fe8d' }

          it 'is valid' do
            assert document.validate_document(fingerprint, true), 'Document should be valid'
          end
        end
      end

      describe 'signature_wrapping_attack' do
        let(:document_data) { read_invalid_response("signature_wrapping_attack.xml.base64") }
        let(:document) { OneLogin::RubySaml::Response.new(document_data).document }
        let(:fingerprint) { 'afe71c28ef740bc87425be13a2263d37971da1f9' }

        it 'is invalid' do
          assert !document.validate_document(fingerprint, true), 'Document should be invalid'
        end
      end

      describe 'signature wrapping attack - doubled SAML response body' do
        let(:document_data) { read_invalid_response("response_with_doubled_signed_assertion.xml") }
        let(:document) { OneLogin::RubySaml::Response.new(document_data) }
        let(:fingerprint) { '4b68c453c7d994aad9025c99d5efcf566287fe8d' }

        it 'is valid, but the unsigned information is ignored in favour of the signed information' do
          assert document.document.validate_document(fingerprint, true), 'Document should be valid'
          assert_equal 'someone@example.org', document.name_id, 'Document should expose only signed, valid details'
        end
      end

      describe 'signature wrapping attack - concealed SAML response body' do
        let(:document_data) { read_invalid_response("response_with_concealed_signed_assertion.xml") }
        let(:document) { OneLogin::RubySaml::Response.new(document_data) }
        let(:fingerprint) { '4b68c453c7d994aad9025c99d5efcf566287fe8d' }

        it 'is valid, but fails to retrieve information' do
          assert document.document.validate_document(fingerprint, true), 'Document should be valid'
          assert document.name_id.nil?, 'Document should expose only signed, valid details'
        end
      end
    end

    describe '#validate_document_with_cert' do
      describe 'with valid document ' do
        describe 'when response has cert' do
          let(:document_data) { read_response('response_with_signed_message_and_assertion.xml') }
          let(:document) { OneLogin::RubySaml::Response.new(document_data).document }
          let(:idp_cert) { OpenSSL::X509::Certificate.new(ruby_saml_cert_text) }
          let(:fingerprint) { '4b68c453c7d994aad9025c99d5efcf566287fe8d' }

          it 'is valid' do
            assert document.validate_document_with_cert(idp_cert), 'Document should be valid'
          end
        end
        
        describe 'when response has no cert but you have local cert' do
          let(:document) { OneLogin::RubySaml::Response.new(response_document_valid_signed_without_x509certificate).document }
          let(:idp_cert) { OpenSSL::X509::Certificate.new(ruby_saml_cert_text) }

          it 'is valid' do
            assert document.validate_document_with_cert(idp_cert), 'Document should be valid'
          end
        end
      end
    end
  end
end
