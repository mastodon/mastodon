require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

require 'onelogin/ruby-saml/metadata'

class MetadataTest < Minitest::Test

  describe 'Metadata' do
    let(:settings)          { OneLogin::RubySaml::Settings.new }
    let(:xml_text)          { OneLogin::RubySaml::Metadata.new.generate(settings, false) }
    let(:xml_doc)           { REXML::Document.new(xml_text) }
    let(:spsso_descriptor)  { REXML::XPath.first(xml_doc, "//md:SPSSODescriptor") }
    let(:acs)               { REXML::XPath.first(xml_doc, "//md:AssertionConsumerService") }

    before do
      settings.issuer = "https://example.com"
      settings.name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
      settings.assertion_consumer_service_url = "https://foo.example/saml/consume"
    end

    it "generates Pretty Print Service Provider Metadata" do
      xml_text = OneLogin::RubySaml::Metadata.new.generate(settings, true)
      # assert correct xml declaration
      start = "<?xml version='1.0' encoding='UTF-8'?>\n<md:EntityDescriptor"
      assert_equal xml_text[0..start.length-1],start

      assert_equal "https://example.com", REXML::XPath.first(xml_doc, "//md:EntityDescriptor").attribute("entityID").value

      assert_equal "urn:oasis:names:tc:SAML:2.0:protocol", spsso_descriptor.attribute("protocolSupportEnumeration").value
      assert_equal "false", spsso_descriptor.attribute("AuthnRequestsSigned").value
      assert_equal "false", spsso_descriptor.attribute("WantAssertionsSigned").value

      assert_equal "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress", REXML::XPath.first(xml_doc, "//md:NameIDFormat").text.strip

      assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST", acs.attribute("Binding").value
      assert_equal "https://foo.example/saml/consume", acs.attribute("Location").value

      assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
    end

    it "generates Service Provider Metadata" do
      settings.single_logout_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
      settings.single_logout_service_url = "https://foo.example/saml/sls"
      xml_metadata = OneLogin::RubySaml::Metadata.new.generate(settings, false)

      start = "<?xml version='1.0' encoding='UTF-8'?><md:EntityDescriptor"
      assert_equal xml_metadata[0..start.length-1],start

      doc_metadata = REXML::Document.new(xml_metadata)
      sls = REXML::XPath.first(doc_metadata, "//md:SingleLogoutService")

      assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect", sls.attribute("Binding").value
      assert_equal "https://foo.example/saml/sls", sls.attribute("Location").value
      assert_equal "https://foo.example/saml/sls", sls.attribute("ResponseLocation").value
      assert_nil sls.attribute("isDefault")
      assert_nil sls.attribute("index")

      assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
    end

    it "generates Service Provider Metadata with single logout service" do
      start = "<?xml version='1.0' encoding='UTF-8'?><md:EntityDescriptor"
      assert_equal xml_text[0..start.length-1], start

      assert_equal "https://example.com", REXML::XPath.first(xml_doc, "//md:EntityDescriptor").attribute("entityID").value

      assert_equal "urn:oasis:names:tc:SAML:2.0:protocol", spsso_descriptor.attribute("protocolSupportEnumeration").value
      assert_equal "false", spsso_descriptor.attribute("AuthnRequestsSigned").value
      assert_equal "false", spsso_descriptor.attribute("WantAssertionsSigned").value

      assert_equal "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress", REXML::XPath.first(xml_doc, "//md:NameIDFormat").text.strip

      assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST", acs.attribute("Binding").value
      assert_equal "https://foo.example/saml/consume", acs.attribute("Location").value

      assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
    end

    describe "WantAssertionsSigned" do
      it "generates Service Provider Metadata with WantAssertionsSigned = false" do
        settings.security[:want_assertions_signed] = false
        assert_equal "false", spsso_descriptor.attribute("WantAssertionsSigned").value
        assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
      end

      it "generates Service Provider Metadata with WantAssertionsSigned = true" do
        settings.security[:want_assertions_signed] = true
        assert_equal "true", spsso_descriptor.attribute("WantAssertionsSigned").value
        assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
      end
    end

    describe "with a sign/encrypt certificate" do
      let(:key_descriptors) do
        REXML::XPath.match(
          xml_doc,
          "//md:KeyDescriptor",
          "md" => "urn:oasis:names:tc:SAML:2.0:metadata"
        )
      end
      let(:cert_nodes) do
        REXML::XPath.match(
          xml_doc,
          "//md:KeyDescriptor/ds:KeyInfo/ds:X509Data/ds:X509Certificate",
          "md" => "urn:oasis:names:tc:SAML:2.0:metadata",
          "ds" => "http://www.w3.org/2000/09/xmldsig#"
        )
      end
      let(:cert)  { OpenSSL::X509::Certificate.new(Base64.decode64(cert_nodes[0].text)) }

      before do
        settings.certificate = ruby_saml_cert_text
      end

      it "generates Service Provider Metadata with X509Certificate for sign" do
        assert_equal 1, key_descriptors.length
        assert_equal "signing", key_descriptors[0].attribute("use").value

        assert_equal 1, cert_nodes.length
        assert_equal ruby_saml_cert.to_der, cert.to_der

        assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
      end

      describe "and signed authentication requests" do
        before do
          settings.security[:authn_requests_signed] = true
        end

        it "generates Service Provider Metadata with AuthnRequestsSigned" do
          assert_equal "true", spsso_descriptor.attribute("AuthnRequestsSigned").value
          assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
        end
      end

      describe "and encrypted assertions" do
        before do
          settings.security[:want_assertions_encrypted] = true
        end

        it "generates Service Provider Metadata with X509Certificate for encrypt" do
          assert_equal 2, key_descriptors.length

          assert_equal "encryption", key_descriptors[1].attribute("use").value

          assert_equal 2, cert_nodes.length
          assert_equal cert_nodes[0].text, cert_nodes[1].text
          assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
        end
      end
    end

    describe "with a future SP certificate" do
      let(:key_descriptors) do
        REXML::XPath.match(
          xml_doc,
          "//md:KeyDescriptor",
          "md" => "urn:oasis:names:tc:SAML:2.0:metadata"
        )
      end
      let(:cert_nodes) do
        REXML::XPath.match(
          xml_doc,
          "//md:KeyDescriptor/ds:KeyInfo/ds:X509Data/ds:X509Certificate",
          "md" => "urn:oasis:names:tc:SAML:2.0:metadata",
          "ds" => "http://www.w3.org/2000/09/xmldsig#"
        )
      end

      before do
        settings.certificate = ruby_saml_cert_text
        settings.certificate_new = ruby_saml_cert_text2
      end

      it "generates Service Provider Metadata with 2 X509Certificate for sign" do
        assert_equal 2, key_descriptors.length
        assert_equal "signing", key_descriptors[0].attribute("use").value
        assert_equal "signing", key_descriptors[1].attribute("use").value

        cert = OpenSSL::X509::Certificate.new(Base64.decode64(cert_nodes[0].text))
        cert_new = OpenSSL::X509::Certificate.new(Base64.decode64(cert_nodes[1].text))

        assert_equal 2, cert_nodes.length
        assert_equal ruby_saml_cert.to_der, cert.to_der
        assert_equal ruby_saml_cert2.to_der, cert_new.to_der

        assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
      end

      describe "and signed authentication requests" do
        before do
          settings.security[:authn_requests_signed] = true
        end

        it "generates Service Provider Metadata with AuthnRequestsSigned" do
          assert_equal "true", spsso_descriptor.attribute("AuthnRequestsSigned").value
          assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
        end
      end

      describe "and encrypted assertions" do
        before do
          settings.security[:want_assertions_encrypted] = true
        end

        it "generates Service Provider Metadata with X509Certificate for encrypt" do
          assert_equal 4, key_descriptors.length
          assert_equal "signing", key_descriptors[0].attribute("use").value
          assert_equal "encryption", key_descriptors[1].attribute("use").value
          assert_equal "signing", key_descriptors[2].attribute("use").value
          assert_equal "encryption", key_descriptors[3].attribute("use").value

          assert_equal 4, cert_nodes.length
          assert_equal cert_nodes[0].text, cert_nodes[1].text
          assert_equal cert_nodes[2].text, cert_nodes[3].text
          assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
        end
      end

    end

    describe "when attribute service is configured with multiple attribute values" do
      let(:attr_svc)  { REXML::XPath.first(xml_doc, "//md:AttributeConsumingService") }
      let(:req_attr)  { REXML::XPath.first(xml_doc, "//md:RequestedAttribute") }

      before do
        settings.attribute_consuming_service.configure do
          service_name "Test Service"
          add_attribute(:name => 'Name', :name_format => 'Name Format', :friendly_name => 'Friendly Name', :attribute_value => ['Attribute Value One', false])
        end
      end

      it "generates attribute service" do
        assert_equal "true", attr_svc.attribute("isDefault").value
        assert_equal "1", attr_svc.attribute("index").value
        assert_equal REXML::XPath.first(xml_doc, "//md:ServiceName").text.strip, "Test Service"

        assert_equal "Name", req_attr.attribute("Name").value
        assert_equal "Name Format", req_attr.attribute("NameFormat").value
        assert_equal "Friendly Name", req_attr.attribute("FriendlyName").value

        attribute_values = REXML::XPath.match(xml_doc, "//saml:AttributeValue").map(&:text)
        assert_equal "Attribute Value One", attribute_values[0]
        assert_equal 'false', attribute_values[1]

        assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
      end
    end

    describe "when attribute service is configured" do
      let(:attr_svc) { REXML::XPath.first(xml_doc, '//md:AttributeConsumingService') }
      let(:req_attr) { REXML::XPath.first(xml_doc, '//md:RequestedAttribute') }

      before do
        settings.attribute_consuming_service.configure do
          service_name "Test Service"
          add_attribute(:name => 'active', :name_format => 'format', :friendly_name => 'Active', :attribute_value => true)
        end
      end

      it "generates attribute service" do
        assert_equal "true", attr_svc.attribute("isDefault").value
        assert_equal "1", attr_svc.attribute("index").value
        assert_equal REXML::XPath.first(xml_doc, "//md:ServiceName").text.strip, "Test Service"

        assert_equal 'active', req_attr.attribute('Name').value
        assert_equal 'format', req_attr.attribute('NameFormat').value
        assert_equal 'Active', req_attr.attribute('FriendlyName').value
        assert_equal 'true', REXML::XPath.first(xml_doc, '//saml:AttributeValue').text.strip

        assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
      end

      describe "#service_name" do
        before do
          settings.attribute_consuming_service.service_name("Test2 Service")
        end

        it "change service name" do
          assert_equal REXML::XPath.first(xml_doc, "//md:ServiceName").text.strip, "Test2 Service"
        end
      end

      describe "#service_index" do
        before do
          settings.attribute_consuming_service.service_index(2)
        end

        it "change service index" do
          assert_equal "2", attr_svc.attribute("index").value
        end
      end
    end

    describe "when the settings indicate to sign (embedded) metadata" do
      before do
        settings.security[:metadata_signed] = true
        settings.certificate = ruby_saml_cert_text
        settings.private_key = ruby_saml_key_text
      end

      it "creates a signed metadata" do
        assert_match %r[<ds:SignatureValue>([a-zA-Z0-9/+=]+)</ds:SignatureValue>]m, xml_text
        assert_match %r[<ds:SignatureMethod Algorithm='http://www.w3.org/2000/09/xmldsig#rsa-sha1'/>], xml_text
        assert_match %r[<ds:DigestMethod Algorithm='http://www.w3.org/2000/09/xmldsig#sha1'/>], xml_text
        signed_metadata = XMLSecurity::SignedDocument.new(xml_text)
        assert signed_metadata.validate_document(ruby_saml_cert_fingerprint, false)

        assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
      end

      describe "when digest and signature methods are specified" do
        before do
          settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256
          settings.security[:digest_method] = XMLSecurity::Document::SHA512
        end

        it "creates a signed metadata with specified digest and signature methods" do
          assert_match %r[<ds:SignatureValue>([a-zA-Z0-9/+=]+)</ds:SignatureValue>]m, xml_text
          assert_match %r[<ds:SignatureMethod Algorithm='http://www.w3.org/2001/04/xmldsig-more#rsa-sha256'/>], xml_text
          assert_match %r[<ds:DigestMethod Algorithm='http://www.w3.org/2001/04/xmlenc#sha512'/>], xml_text

          signed_metadata_2 = XMLSecurity::SignedDocument.new(xml_text)

          assert signed_metadata_2.validate_document(ruby_saml_cert_fingerprint, false)

          assert validate_xml!(xml_text, "saml-schema-metadata-2.0.xsd")
        end
      end
    end
  end
end
