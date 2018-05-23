require 'simplecov'

SimpleCov.start do
  add_filter "test/"
  add_filter "vendor/"
  add_filter "lib/onelogin/ruby-saml/logging.rb"
end

require 'stringio'
require 'rubygems'
require 'bundler'
require 'minitest/autorun'
require 'mocha/setup'
require 'timecop'

Bundler.require :default, :test

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'onelogin/ruby-saml/logging'

TEST_LOGGER = Logger.new(StringIO.new)
OneLogin::RubySaml::Logging.logger = TEST_LOGGER

class Minitest::Test
  def fixture(document, base64 = true)
    response = Dir.glob(File.join(File.dirname(__FILE__), "responses", "#{document}*")).first
    if base64 && response =~ /\.xml$/
      Base64.encode64(File.read(response))
    else
      File.read(response)
    end
  end

  def read_response(response)
    File.read(File.join(File.dirname(__FILE__), "responses", response))
  end

  def read_invalid_response(response)
    File.read(File.join(File.dirname(__FILE__), "responses", "invalids", response))
  end

  def read_logout_request(request)
    File.read(File.join(File.dirname(__FILE__), "logout_requests", request))
  end

  def read_certificate(certificate)
    File.read(File.join(File.dirname(__FILE__), "certificates", certificate))
  end

  def response_document_valid_signed
    @response_document_valid_signed ||= read_response("valid_response.xml.base64")
  end

  def response_document_valid_signed_without_x509certificate
    @response_document_valid_signed_without_x509certificate ||= read_response("valid_response_without_x509certificate.xml.base64")
  end

  def response_document_without_recipient
    @response_document_without_recipient ||= read_response("response_with_undefined_recipient.xml.base64")
  end

  def response_document_without_recipient_with_time_updated
    doc = Base64.decode64(response_document_without_recipient)
    doc.gsub!(/NotBefore=\"(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z\"/, "NotBefore=\"#{(Time.now-300).getutc.strftime("%Y-%m-%dT%XZ")}\"")
    doc.gsub!(/NotOnOrAfter=\"(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z\"/, "NotOnOrAfter=\"#{(Time.now+300).getutc.strftime("%Y-%m-%dT%XZ")}\"")
    Base64.encode64(doc)
  end

  def response_document_without_attributes
    @response_document_without_attributes ||= read_response("response_without_attributes.xml.base64")
  end

  def response_document_without_reference_uri
    @response_document_without_reference_uri ||= read_response("response_without_reference_uri.xml.base64")
  end

  def response_document_with_signed_assertion
    @response_document_with_signed_assertion ||= read_response("response_with_signed_assertion.xml.base64")
  end

  def response_document_with_signed_assertion_2
    @response_document_with_signed_assertion_2 ||= read_response("response_with_signed_assertion_2.xml.base64")
  end

  def response_document_with_ds_namespace_at_the_root
    @response_document_with_ds_namespace_at_the_root ||= read_response("response_with_ds_namespace_at_the_root.xml.base64")
  end

  def response_document_unsigned
    @response_document_unsigned ||= read_response("response_unsigned_xml_base64")
  end

  def response_document_with_saml2_namespace
    @response_document_with_saml2_namespace ||= read_response("response_with_saml2_namespace.xml.base64")
  end

  def ampersands_document
    @ampersands_response ||= read_response("response_with_ampersands.xml.base64")
  end

  def response_document_no_cert_and_encrypted_attrs
    @response_document_no_cert_and_encrypted_attrs ||= Base64.encode64(read_response("response_no_cert_and_encrypted_attrs.xml"))
  end

  def response_document_wrapped
    @response_document_wrapped ||= read_response("response_wrapped.xml.base64")
  end

  def response_document_assertion_wrapped
    @response_document_assertion_wrapped ||= read_response("response_assertion_wrapped.xml.base64")
  end

  def response_document_encrypted_nameid
    @response_document_encrypted_nameid ||= File.read(File.join(File.dirname(__FILE__), 'responses', 'response_encrypted_nameid.xml.base64'))
  end

  def signed_message_encrypted_unsigned_assertion
    @signed_message_encrypted_unsigned_assertion ||= File.read(File.join(File.dirname(__FILE__), 'responses', 'signed_message_encrypted_unsigned_assertion.xml.base64'))    
  end

  def signed_message_encrypted_signed_assertion
    @signed_message_encrypted_signed_assertion ||= File.read(File.join(File.dirname(__FILE__), 'responses', 'signed_message_encrypted_signed_assertion.xml.base64'))    
  end

  def unsigned_message_encrypted_signed_assertion
    @unsigned_message_encrypted_signed_assertion ||= File.read(File.join(File.dirname(__FILE__), 'responses', 'unsigned_message_encrypted_signed_assertion.xml.base64'))    
  end

  def unsigned_message_encrypted_unsigned_assertion
    @unsigned_message_encrypted_unsigned_assertion ||= File.read(File.join(File.dirname(__FILE__), 'responses', 'unsigned_message_encrypted_unsigned_assertion.xml.base64'))
  end

  def response_document_encrypted_attrs
    @response_document_encrypted_attrs ||= File.read(File.join(File.dirname(__FILE__), 'responses', 'response_encrypted_attrs.xml.base64'))
  end

  def response_document_double_status_code
    @response_document_double_status_code ||= File.read(File.join(File.dirname(__FILE__), 'responses', 'response_double_status_code.xml.base64'))
  end

  def signature_fingerprint_1
    @signature_fingerprint1 ||= "C5:19:85:D9:47:F1:BE:57:08:20:25:05:08:46:EB:27:F6:CA:B7:83"
  end

  # certificate used on response_with_undefined_recipient
  def signature_1  
    @signature1 ||= read_certificate("certificate1")
  end

  # certificate used on response_document_with_signed_assertion_2
  def certificate_without_head_foot
    @certificate_without_head_foot ||= read_certificate("certificate_without_head_foot")
  end

  def idp_metadata_descriptor
    @idp_metadata_descriptor ||= File.read(File.join(File.dirname(__FILE__), 'metadata', 'idp_descriptor.xml'))
  end

  def idp_metadata_descriptor2
    @idp_metadata_descriptor2 ||= File.read(File.join(File.dirname(__FILE__), 'metadata', 'idp_descriptor_2.xml'))
  end

  def idp_metadata_descriptor3
    @idp_metadata_descriptor3 ||= File.read(File.join(File.dirname(__FILE__), 'metadata', 'idp_descriptor_3.xml'))
  end

  def no_idp_metadata_descriptor
    @no_idp_metadata_descriptor ||= File.read(File.join(File.dirname(__FILE__), 'metadata', 'no_idp_descriptor.xml'))
  end

  def idp_metadata_multiple_descriptors
    @idp_metadata_multiple_descriptors ||= File.read(File.join(File.dirname(__FILE__), 'metadata', 'idp_multiple_descriptors.xml'))
  end

  def idp_metadata_multiple_certs
    @idp_metadata_multiple_descriptors ||= File.read(File.join(File.dirname(__FILE__), 'metadata', 'idp_metadata_multi_certs.xml'))
  end

  def idp_metadata_multiple_signing_certs
    @idp_metadata_multiple_signing_certs ||= File.read(File.join(File.dirname(__FILE__), 'metadata', 'idp_metadata_multi_signing_certs.xml'))
  end

  def idp_metadata_same_sign_and_encrypt_cert
    @idp_metadata_same_sign_and_encrypt_cert ||= File.read(File.join(File.dirname(__FILE__), 'metadata', 'idp_metadata_same_sign_and_encrypt_cert.xml'))
  end

  def idp_metadata_different_sign_and_encrypt_cert
    @idp_metadata_different_sign_and_encrypt_cert ||= File.read(File.join(File.dirname(__FILE__), 'metadata', 'idp_metadata_different_sign_and_encrypt_cert.xml'))
  end

  def logout_request_document
    unless @logout_request_document
      xml = read_logout_request("slo_request.xml")
      deflated = Zlib::Deflate.deflate(xml, 9)[2..-5]
      @logout_request_document = Base64.encode64(deflated)
    end
    @logout_request_document
  end

  def logout_request_document_with_name_id_format
    unless @logout_request_document_with_name_id_format
      xml = read_logout_request("slo_request_with_name_id_format.xml")
      deflated = Zlib::Deflate.deflate(xml, 9)[2..-5]
      @logout_request_document_with_name_id_format = Base64.encode64(deflated)
    end
    @logout_request_document_with_name_id_format
  end

  def logout_request_xml_with_session_index
    @logout_request_xml_with_session_index ||= File.read(File.join(File.dirname(__FILE__), 'logout_requests', 'slo_request_with_session_index.xml'))
  end

  def invalid_logout_request_document
    unless @invalid_logout_request_document
      xml = File.read(File.join(File.dirname(__FILE__), 'logout_requests', 'invalid_slo_request.xml'))
      deflated = Zlib::Deflate.deflate(xml, 9)[2..-5]
      @invalid_logout_request_document = Base64.encode64(deflated)
    end
    @invalid_logout_request_document
  end

  def logout_request_base64
    @logout_request_base64 ||= File.read(File.join(File.dirname(__FILE__), 'logout_requests', 'slo_request.xml.base64'))
  end

  def logout_request_deflated_base64
    @logout_request_deflated_base64 ||= File.read(File.join(File.dirname(__FILE__), 'logout_requests', 'slo_request_deflated.xml.base64'))
  end

  def ruby_saml_cert
    @ruby_saml_cert ||= OpenSSL::X509::Certificate.new(ruby_saml_cert_text)
  end

  def ruby_saml_cert2
    @ruby_saml_cert2 ||= OpenSSL::X509::Certificate.new(ruby_saml_cert_text2)
  end

  def ruby_saml_cert_fingerprint
    @ruby_saml_cert_fingerprint ||= Digest::SHA1.hexdigest(ruby_saml_cert.to_der).scan(/../).join(":")
  end

  def ruby_saml_cert_text
    read_certificate("ruby-saml.crt")
  end

  def ruby_saml_cert_text2
    read_certificate("ruby-saml-2.crt")
  end

  def ruby_saml_key
    @ruby_saml_key ||= OpenSSL::PKey::RSA.new(ruby_saml_key_text)
  end

  def ruby_saml_key_text
    read_certificate("ruby-saml.key")
  end

  #
  # logoutresponse fixtures
  #
  def random_id
    "_#{OneLogin::RubySaml::Utils.uuid}"
  end

  #
  # decodes a base64 encoded SAML response for use in SloLogoutresponse tests
  #
  def decode_saml_response_payload(unauth_url)
    payload = CGI.unescape(unauth_url.split("SAMLResponse=").last)
    decoded = Base64.decode64(payload)

    zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
    inflated = zstream.inflate(decoded)
    zstream.finish
    zstream.close
    inflated
  end

  #
  # decodes a base64 encoded SAML request for use in Logoutrequest tests
  #
  def decode_saml_request_payload(unauth_url)
    payload = CGI.unescape(unauth_url.split("SAMLRequest=").last)
    decoded = Base64.decode64(payload)

    zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
    inflated = zstream.inflate(decoded)
    zstream.finish
    zstream.close
    inflated
  end

  SCHEMA_DIR = File.expand_path(File.join(__FILE__, '../../lib/schemas'))

  #
  # validate an xml document against the given schema
  #
  def validate_xml!(document, schema)
    Dir.chdir(SCHEMA_DIR) do
      xsd = if schema.is_a? Nokogiri::XML::Schema
              schema
            else
              Nokogiri::XML::Schema(File.read(schema))
            end

      xml = if document.is_a? Nokogiri::XML::Document
              document
            else
              Nokogiri::XML(document) { |c| c.strict }
            end

      result = xsd.validate(xml)

      if result.length != 0
        raise "Schema validation failed! XSD validation errors: #{result.join(", ")}"
      else
        true
      end
    end
  end
end
