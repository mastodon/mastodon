require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

require 'onelogin/ruby-saml/settings'

class SettingsTest < Minitest::Test

  describe "Settings" do
    before do
      @settings = OneLogin::RubySaml::Settings.new
    end

    it "should provide getters and settings" do
      accessors = [
        :idp_entity_id, :idp_sso_target_url, :idp_slo_target_url,
        :idp_cert, :idp_cert_fingerprint, :idp_cert_fingerprint_algorithm, :idp_cert_multi,
        :idp_attribute_names, :issuer, :assertion_consumer_service_url, :assertion_consumer_service_binding,
        :single_logout_service_url, :single_logout_service_binding,
        :sp_name_qualifier, :name_identifier_format, :name_identifier_value,
        :sessionindex, :attributes_index, :passive, :force_authn,
        :compress_request, :double_quote_xml_attribute_values, :protocol_binding,
        :security, :certificate, :private_key,
        :authn_context, :authn_context_comparison, :authn_context_decl_ref,
        :assertion_consumer_logout_service_url,
        :assertion_consumer_logout_service_binding
      ]

      accessors.each do |accessor|
        value = Kernel.rand
        @settings.send("#{accessor}=".to_sym, value)
        assert_equal value, @settings.send(accessor)
      end

    end

    it "create settings from hash" do
      config = {
          :assertion_consumer_service_url => "http://app.muda.no/sso",
          :issuer => "http://muda.no",
          :sp_name_qualifier => "http://sso.muda.no",
          :idp_sso_target_url => "http://sso.muda.no/sso",
          :idp_slo_target_url => "http://sso.muda.no/slo",
          :idp_cert_fingerprint => "00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00",
          :name_identifier_format => "urn:oasis:names:tc:SAML:2.0:nameid-format:transient",
          :attributes_index => 30,
          :passive => true,
          :protocol_binding => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'
      }
      @settings = OneLogin::RubySaml::Settings.new(config)

      config.each do |k,v|
        assert_equal v, @settings.send(k)
      end
    end

    it "configure attribute service attributes correctly" do
      @settings.attribute_consuming_service.configure do
        service_name "Test Service"
        add_attribute :name => "Name", :name_format => "Name Format", :friendly_name => "Friendly Name"
      end

      assert_equal @settings.attribute_consuming_service.configured?, true
      assert_equal @settings.attribute_consuming_service.name, "Test Service"
      assert_equal @settings.attribute_consuming_service.attributes, [{:name => "Name", :name_format => "Name Format", :friendly_name => "Friendly Name" }]
    end

    it "does not modify default security settings" do
      settings = OneLogin::RubySaml::Settings.new
      settings.security[:authn_requests_signed] = true
      settings.security[:embed_sign] = true
      settings.security[:digest_method] = XMLSecurity::Document::SHA256
      settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256

      new_settings = OneLogin::RubySaml::Settings.new
      assert_equal new_settings.security[:authn_requests_signed], false
      assert_equal new_settings.security[:embed_sign], false
      assert_equal new_settings.security[:digest_method], XMLSecurity::Document::SHA1
      assert_equal new_settings.security[:signature_method], XMLSecurity::Document::RSA_SHA1
    end

    describe "#single_logout_service_url" do
      it "when single_logout_service_url is nil but assertion_consumer_logout_service_url returns its value" do
        @settings.single_logout_service_url = nil
        @settings.assertion_consumer_logout_service_url = "http://app.muda.no/sls"

        assert_equal "http://app.muda.no/sls", @settings.single_logout_service_url
      end
    end

    describe "#single_logout_service_binding" do
      it "when single_logout_service_binding is nil but assertion_consumer_logout_service_binding returns its value" do
        @settings.single_logout_service_binding = nil
        @settings.assertion_consumer_logout_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"

        assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect", @settings.single_logout_service_binding
      end
    end    

    describe "#get_idp_cert" do
      it "returns nil when the cert is an empty string" do
        @settings.idp_cert = ""
        assert_nil @settings.get_idp_cert
      end

      it "returns nil when the cert is nil" do
        @settings.idp_cert = nil
        assert_nil @settings.get_idp_cert
      end

      it "returns the certificate when it is valid" do
        @settings.idp_cert = ruby_saml_cert_text
        assert @settings.get_idp_cert.kind_of? OpenSSL::X509::Certificate
      end

      it "raises when the certificate is not valid" do
        # formatted but invalid cert
        @settings.idp_cert = read_certificate("formatted_certificate")
        assert_raises(OpenSSL::X509::CertificateError) {
          @settings.get_idp_cert
        }
      end
    end

    describe "#get_idp_cert_multi" do
      it "returns nil when the value is empty" do
        @settings.idp_cert = {}
        assert_nil @settings.get_idp_cert_multi
      end

      it "returns nil when the idp_cert_multi is nil or empty" do
        @settings.idp_cert_multi = nil
        assert_nil @settings.get_idp_cert_multi
      end

      it "returns partial hash when contains some values" do
        empty_multi = {
          :signing => [],
          :encryption => []
        }

        @settings.idp_cert_multi = {
          :signing => []
        }
        assert_equal empty_multi, @settings.get_idp_cert_multi

        @settings.idp_cert_multi = {
          :encryption => []
        }
        assert_equal empty_multi, @settings.get_idp_cert_multi

        @settings.idp_cert_multi = {
          :signing => [],
          :encryption => []
        }
        assert_equal empty_multi, @settings.get_idp_cert_multi

        @settings.idp_cert_multi = {
          :yyy => [],
          :zzz => []
        }
        assert_equal empty_multi, @settings.get_idp_cert_multi
      end

      it "returns the hash with certificates when values were valid" do
        certificates = ruby_saml_cert_text
        @settings.idp_cert_multi = {
          :signing => [ruby_saml_cert_text],
          :encryption => [ruby_saml_cert_text],
        }

        assert @settings.get_idp_cert_multi.kind_of? Hash
        assert @settings.get_idp_cert_multi[:signing].kind_of? Array
        assert @settings.get_idp_cert_multi[:encryption].kind_of? Array        
        assert @settings.get_idp_cert_multi[:signing][0].kind_of? OpenSSL::X509::Certificate
        assert @settings.get_idp_cert_multi[:encryption][0].kind_of? OpenSSL::X509::Certificate
      end

      it "raises when there is a cert in idp_cert_multi not valid" do
        certificate = read_certificate("formatted_certificate")

        @settings.idp_cert_multi = {
          :signing => [],
          :encryption => []
        }
        @settings.idp_cert_multi[:signing].push(certificate)
        @settings.idp_cert_multi[:encryption].push(certificate)

        assert_raises(OpenSSL::X509::CertificateError) {
          @settings.get_idp_cert_multi
        }
      end
    end

    describe "#get_sp_cert" do
      it "returns nil when the cert is an empty string" do
        @settings.certificate = ""
        assert_nil @settings.get_sp_cert
      end

      it "returns nil when the cert is nil" do
        @settings.certificate = nil
        assert_nil @settings.get_sp_cert
      end

      it "returns the certificate when it is valid" do
        @settings.certificate = ruby_saml_cert_text
        assert @settings.get_sp_cert.kind_of? OpenSSL::X509::Certificate
      end

      it "raises when the certificate is not valid" do
        # formatted but invalid cert
        @settings.certificate = read_certificate("formatted_certificate")
        assert_raises(OpenSSL::X509::CertificateError) {
          @settings.get_sp_cert
        }
      end

    end

    describe "#get_sp_cert_new" do
      it "returns nil when the cert is an empty string" do
        @settings.certificate_new = ""
        assert_nil @settings.get_sp_cert_new
      end

      it "returns nil when the cert is nil" do
        @settings.certificate_new = nil
        assert_nil @settings.get_sp_cert_new
      end

      it "returns the certificate when it is valid" do
        @settings.certificate_new = ruby_saml_cert_text
        assert @settings.get_sp_cert_new.kind_of? OpenSSL::X509::Certificate
      end

      it "raises when the certificate is not valid" do
        # formatted but invalid cert
        @settings.certificate_new = read_certificate("formatted_certificate")
        assert_raises(OpenSSL::X509::CertificateError) {
          @settings.get_sp_cert_new
        }
      end

    end

    describe "#get_sp_key" do
      it "returns nil when the private key is an empty string" do
        @settings.private_key = ""
        assert_nil @settings.get_sp_key
      end

      it "returns nil when the private key is nil" do
        @settings.private_key = nil
        assert_nil @settings.get_sp_key
      end

      it "returns the private key when it is valid" do
        @settings.private_key = ruby_saml_key_text
        assert @settings.get_sp_key.kind_of? OpenSSL::PKey::RSA
      end

      it "raises when the private key is not valid" do
        # formatted but invalid rsa private key
        @settings.private_key = read_certificate("formatted_rsa_private_key")
        assert_raises(OpenSSL::PKey::RSAError) {
          @settings.get_sp_key
        }
      end

    end

    describe "#get_fingerprint" do
      it "get the fingerprint value when cert and fingerprint in settings are nil" do
        @settings.idp_cert_fingerprint = nil
        @settings.idp_cert = nil
        fingerprint = @settings.get_fingerprint
        assert_nil fingerprint
      end

      it "get the fingerprint value when there is a cert at the settings" do
        @settings.idp_cert_fingerprint = nil
        @settings.idp_cert = ruby_saml_cert_text
        fingerprint = @settings.get_fingerprint
        assert fingerprint.downcase == ruby_saml_cert_fingerprint.downcase
      end

      it "get the fingerprint value when there is a fingerprint at the settings" do
        @settings.idp_cert_fingerprint = ruby_saml_cert_fingerprint
        @settings.idp_cert = nil
        fingerprint = @settings.get_fingerprint
        assert fingerprint.downcase == ruby_saml_cert_fingerprint.downcase
      end

      it "get the fingerprint value when there are cert and fingerprint at the settings" do
        @settings.idp_cert_fingerprint = ruby_saml_cert_fingerprint
        @settings.idp_cert = ruby_saml_cert_text
        fingerprint = @settings.get_fingerprint
        assert fingerprint.downcase == ruby_saml_cert_fingerprint.downcase
      end
    end
  end
end
