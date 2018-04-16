require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

class UtilsTest < Minitest::Test
  describe ".format_cert" do
    let(:formatted_certificate) {read_certificate("formatted_certificate")}
    let(:formatted_chained_certificate) {read_certificate("formatted_chained_certificate")}

    it "returns empty string when the cert is an empty string" do
      cert = ""
      assert_equal "", OneLogin::RubySaml::Utils.format_cert(cert)
    end

    it "returns nil when the cert is nil" do
      cert = nil
      assert_nil OneLogin::RubySaml::Utils.format_cert(cert)
    end

    it "returns the certificate when it is valid" do
      assert_equal formatted_certificate, OneLogin::RubySaml::Utils.format_cert(formatted_certificate)
    end

    it "reformats the certificate when there are spaces and no line breaks" do
      invalid_certificate1 = read_certificate("invalid_certificate1")
      assert_equal formatted_certificate, OneLogin::RubySaml::Utils.format_cert(invalid_certificate1)
    end

    it "reformats the certificate when there are spaces and no headers" do
      invalid_certificate2 = read_certificate("invalid_certificate2")
      assert_equal formatted_certificate, OneLogin::RubySaml::Utils.format_cert(invalid_certificate2)
    end

    it "reformats the certificate when there line breaks and no headers" do
      invalid_certificate3 = read_certificate("invalid_certificate3")
      assert_equal formatted_certificate, OneLogin::RubySaml::Utils.format_cert(invalid_certificate3)
    end

    it "returns the chained certificate when it is a valid chained certificate" do
      assert_equal formatted_chained_certificate, OneLogin::RubySaml::Utils.format_cert(formatted_chained_certificate)
    end

    it "reformats the chained certificate when there are spaces and no line breaks" do
      invalid_chained_certificate1 = read_certificate("invalid_chained_certificate1")
      assert_equal formatted_chained_certificate, OneLogin::RubySaml::Utils.format_cert(invalid_chained_certificate1)
    end

  end

  describe ".format_private_key" do
    let(:formatted_private_key) do
      read_certificate("formatted_private_key")
    end

    it "returns empty string when the private key is an empty string" do
      private_key = ""
      assert_equal "", OneLogin::RubySaml::Utils.format_private_key(private_key)
    end

    it "returns nil when the private key is nil" do
      private_key = nil
      assert_nil OneLogin::RubySaml::Utils.format_private_key(private_key)
    end

    it "returns the private key when it is valid" do
      assert_equal formatted_private_key, OneLogin::RubySaml::Utils.format_private_key(formatted_private_key)
    end

    it "reformats the private key when there are spaces and no line breaks" do
      invalid_private_key1 = read_certificate("invalid_private_key1")
      assert_equal formatted_private_key, OneLogin::RubySaml::Utils.format_private_key(invalid_private_key1)
    end

    it "reformats the private key when there are spaces and no headers" do
      invalid_private_key2 = read_certificate("invalid_private_key2")
      assert_equal formatted_private_key, OneLogin::RubySaml::Utils.format_private_key(invalid_private_key2)
    end

    it "reformats the private key when there line breaks and no headers" do
      invalid_private_key3 = read_certificate("invalid_private_key3")
      assert_equal formatted_private_key, OneLogin::RubySaml::Utils.format_private_key(invalid_private_key3)
    end

    describe "an RSA public key" do
      let(:formatted_rsa_private_key) do
        read_certificate("formatted_rsa_private_key")
      end

      it "returns the private key when it is valid" do
        assert_equal formatted_rsa_private_key, OneLogin::RubySaml::Utils.format_private_key(formatted_rsa_private_key)
      end

      it "reformats the private key when there are spaces and no line breaks" do
        invalid_rsa_private_key1 = read_certificate("invalid_rsa_private_key1")
        assert_equal formatted_rsa_private_key, OneLogin::RubySaml::Utils.format_private_key(invalid_rsa_private_key1)
      end

      it "reformats the private key when there are spaces and no headers" do
        invalid_rsa_private_key2 = read_certificate("invalid_rsa_private_key2")
        assert_equal formatted_private_key, OneLogin::RubySaml::Utils.format_private_key(invalid_rsa_private_key2)
      end

      it "reformats the private key when there line breaks and no headers" do
        invalid_rsa_private_key3 = read_certificate("invalid_rsa_private_key3")
        assert_equal formatted_private_key, OneLogin::RubySaml::Utils.format_private_key(invalid_rsa_private_key3)
      end
    end
  end

  describe "build_query" do
    it "returns the query string" do
      params = {}
      params[:type] = "SAMLRequest"
      params[:data] = "PHNhbWxwOkF1dGhuUmVxdWVzdCBEZXN0aW5hdGlvbj0naHR0cDovL2V4YW1wbGUuY29tP2ZpZWxkPXZhbHVlJyBJRD0nXzk4NmUxZDEwLWVhY2ItMDEzMi01MGRkLTAwOTBmNWRlZGQ3NycgSXNzdWVJbnN0YW50PScyMDE1LTA2LTAxVDIwOjM0OjU5WicgVmVyc2lvbj0nMi4wJyB4bWxuczpzYW1sPSd1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uJyB4bWxuczpzYW1scD0ndXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sJy8+"
      params[:relay_state] = "http://example.com"
      params[:sig_alg] = "http://www.w3.org/2000/09/xmldsig#rsa-sha1"
      query_string = OneLogin::RubySaml::Utils.build_query(params)
      assert_equal "SAMLRequest=PHNhbWxwOkF1dGhuUmVxdWVzdCBEZXN0aW5hdGlvbj0naHR0cDovL2V4YW1wbGUuY29tP2ZpZWxkPXZhbHVlJyBJRD0nXzk4NmUxZDEwLWVhY2ItMDEzMi01MGRkLTAwOTBmNWRlZGQ3NycgSXNzdWVJbnN0YW50PScyMDE1LTA2LTAxVDIwOjM0OjU5WicgVmVyc2lvbj0nMi4wJyB4bWxuczpzYW1sPSd1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uJyB4bWxuczpzYW1scD0ndXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sJy8%2B&RelayState=http%3A%2F%2Fexample.com&SigAlg=http%3A%2F%2Fwww.w3.org%2F2000%2F09%2Fxmldsig%23rsa-sha1", query_string
    end
  end

  describe "#verify_signature" do
    before do
      @params = {}
      @params[:cert] = ruby_saml_cert
      @params[:sig_alg] = "http://www.w3.org/2000/09/xmldsig#rsa-sha1"
      @params[:query_string] = "SAMLRequest=PHNhbWxwOkF1dGhuUmVxdWVzdCBEZXN0aW5hdGlvbj0naHR0cDovL2V4YW1wbGUuY29tP2ZpZWxkPXZhbHVlJyBJRD0nXzk4NmUxZDEwLWVhY2ItMDEzMi01MGRkLTAwOTBmNWRlZGQ3NycgSXNzdWVJbnN0YW50PScyMDE1LTA2LTAxVDIwOjM0OjU5WicgVmVyc2lvbj0nMi4wJyB4bWxuczpzYW1sPSd1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uJyB4bWxuczpzYW1scD0ndXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sJy8%2B&RelayState=http%3A%2F%2Fexample.com&SigAlg=http%3A%2F%2Fwww.w3.org%2F2000%2F09%2Fxmldsig%23rsa-sha1"
    end

    it "returns true when the signature is valid" do
      @params[:signature] = "uWJm/T4gKLYEsVu1j/ZmjDeHp9zYPXPXWTXHFJZf2KKnWg57fUw3x2l6KTyRQ+Xjigb+sfYdGnnwmIz6KngXYRnh7nO6inspRLWOwkqQFy9iR9LDlMcfpXV/0g3oAxBxO6tX8MUHqR2R62SYZRGd1rxC9apg4vQiP97+atOI8t4="
      assert OneLogin::RubySaml::Utils.verify_signature(@params)
    end

    it "returns false when the signature is invalid" do
      @params[:signature] = "uWJm/InVaLiDsVu1j/ZmjDeHp9zYPXPXWTXHFJZf2KKnWg57fUw3x2l6KTyRQ+Xjigb+sfYdGnnwmIz6KngXYRnh7nO6inspRLWOwkqQFy9iR9LDlMcfpXV/0g3oAxBxO6tX8MUHqR2R62SYZRGd1rxC9apg4vQiP97+atOI8t4="
      assert !OneLogin::RubySaml::Utils.verify_signature(@params)
    end
  end

  describe "#status_error_msg" do
    it "returns a error msg with a status message" do
      error_msg = "The status code of the Logout Response was not Success"
      status_code = "urn:oasis:names:tc:SAML:2.0:status:Requester"
      status_message = "The request could not be performed due to an error on the part of the requester."
      status_error_msg = OneLogin::RubySaml::Utils.status_error_msg(error_msg, status_code, status_message)
      assert_equal = "The status code of the Logout Response was not Success, was Requester -> The request could not be performed due to an error on the part of the requester.", status_error_msg

      status_error_msg2 = OneLogin::RubySaml::Utils.status_error_msg(error_msg, status_code)
      assert_equal = "The status code of the Logout Response was not Success, was Requester", status_error_msg2

      status_error_msg3 = OneLogin::RubySaml::Utils.status_error_msg(error_msg)
      assert_equal = "The status code of the Logout Response was not Success", status_error_msg3
    end
  end

  describe "Utils" do

    describe ".uuid" do
      it "returns a uuid starting with an underscore" do
        assert_match /^_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, OneLogin::RubySaml::Utils.uuid
      end

      it "doesn't return the same value twice" do
        refute_equal OneLogin::RubySaml::Utils.uuid, OneLogin::RubySaml::Utils.uuid
      end
    end

    describe 'uri_match' do
      it 'matches two urls' do
        destination = 'http://www.example.com/test?var=stuff'
        settings = 'http://www.example.com/test?var=stuff'
        assert OneLogin::RubySaml::Utils.uri_match?(destination, settings)
      end

      it 'fails to match two urls' do
        destination = 'http://www.example.com/test?var=stuff'
        settings = 'http://www.example.com/othertest?var=stuff'
        assert !OneLogin::RubySaml::Utils.uri_match?(destination, settings)
      end

      it "matches two URLs if the scheme case doesn't match" do
        destination = 'http://www.example.com/test?var=stuff'
        settings = 'HTTP://www.example.com/test?var=stuff'
        assert OneLogin::RubySaml::Utils.uri_match?(destination, settings)
      end

      it "matches two URLs if the host case doesn't match" do
        destination = 'http://www.EXAMPLE.com/test?var=stuff'
        settings = 'http://www.example.com/test?var=stuff'
        assert OneLogin::RubySaml::Utils.uri_match?(destination, settings)
      end

      it "fails to match two URLs if the path case doesn't match" do
        destination = 'http://www.example.com/TEST?var=stuff'
        settings = 'http://www.example.com/test?var=stuff'
        assert !OneLogin::RubySaml::Utils.uri_match?(destination, settings)
      end

      it "fails to match two URLs if the query case doesn't match" do
        destination = 'http://www.example.com/test?var=stuff'
        settings = 'http://www.example.com/test?var=STUFF'
        assert !OneLogin::RubySaml::Utils.uri_match?(destination, settings)
      end

      it 'matches two non urls' do
        destination = 'stuff'
        settings = 'stuff'
        assert OneLogin::RubySaml::Utils.uri_match?(destination, settings)
      end

      it "fails to match two non urls" do
        destination = 'stuff'
        settings = 'not stuff'
        assert !OneLogin::RubySaml::Utils.uri_match?(destination, settings)
      end
    end

    describe 'element_text' do
      it 'returns the element text' do
        element = REXML::Document.new('<element>element text</element>').elements.first
        assert_equal 'element text', OneLogin::RubySaml::Utils.element_text(element)
      end

      it 'returns all segments of the element text' do
        element = REXML::Document.new('<element>element <!-- comment -->text</element>').elements.first
        assert_equal 'element text', OneLogin::RubySaml::Utils.element_text(element)
      end

      it 'returns normalized element text' do
        element = REXML::Document.new('<element>element &amp; text</element>').elements.first
        assert_equal 'element & text', OneLogin::RubySaml::Utils.element_text(element)
      end

      it 'returns the CDATA element text' do
        element = REXML::Document.new('<element><![CDATA[element & text]]></element>').elements.first
        assert_equal 'element & text', OneLogin::RubySaml::Utils.element_text(element)
      end

      it 'returns the element text with newlines and additional whitespace' do
        element = REXML::Document.new("<element>  element \n text  </element>").elements.first
        assert_equal "  element \n text  ", OneLogin::RubySaml::Utils.element_text(element)
      end

      it 'returns nil when element is nil' do
        assert_nil OneLogin::RubySaml::Utils.element_text(nil)
      end

      it 'returns empty string when element has no text' do
        element = REXML::Document.new('<element></element>').elements.first
        assert_equal '', OneLogin::RubySaml::Utils.element_text(element)
      end

    end
  end
end
