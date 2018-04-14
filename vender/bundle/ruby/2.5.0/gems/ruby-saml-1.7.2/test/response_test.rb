require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

require 'onelogin/ruby-saml/response'

class RubySamlTest < Minitest::Test

  describe "Response" do

    let(:settings) { OneLogin::RubySaml::Settings.new }
    let(:response) { OneLogin::RubySaml::Response.new(response_document_without_recipient) }
    let(:response_without_attributes) { OneLogin::RubySaml::Response.new(response_document_without_attributes) }
    let(:response_with_multiple_attribute_statements) { OneLogin::RubySaml::Response.new(fixture(:response_with_multiple_attribute_statements)) }
    let(:response_without_reference_uri) { OneLogin::RubySaml::Response.new(response_document_without_reference_uri) }
    let(:response_with_signed_assertion) { OneLogin::RubySaml::Response.new(response_document_with_signed_assertion) }
    let(:response_with_ds_namespace_at_the_root) { OneLogin::RubySaml::Response.new(response_document_with_ds_namespace_at_the_root)}
    let(:response_unsigned) { OneLogin::RubySaml::Response.new(response_document_unsigned) }
    let(:response_wrapped) { OneLogin::RubySaml::Response.new(response_document_wrapped) }
    let(:response_multiple_attr_values) { OneLogin::RubySaml::Response.new(fixture(:response_with_multiple_attribute_values)) }
    let(:response_valid_signed) { OneLogin::RubySaml::Response.new(response_document_valid_signed) }
    let(:response_valid_signed_without_recipient) { OneLogin::RubySaml::Response.new(response_document_valid_signed, {:skip_recipient_check => true })}
    let(:response_valid_signed_without_x509certificate) { OneLogin::RubySaml::Response.new(response_document_valid_signed_without_x509certificate) }
    let(:response_no_id) { OneLogin::RubySaml::Response.new(read_invalid_response("no_id.xml.base64")) }
    let(:response_no_version) { OneLogin::RubySaml::Response.new(read_invalid_response("no_saml2.xml.base64")) }
    let(:response_multi_assertion) { OneLogin::RubySaml::Response.new(read_invalid_response("multiple_assertions.xml.base64")) }
    let(:response_no_conditions) { OneLogin::RubySaml::Response.new(read_invalid_response("no_conditions.xml.base64")) }
    let(:response_no_authnstatement) { OneLogin::RubySaml::Response.new(read_invalid_response("no_authnstatement.xml.base64")) }
    let(:response_empty_destination) { OneLogin::RubySaml::Response.new(read_invalid_response("empty_destination.xml.base64")) }
    let(:response_empty_destination_with_skip) { OneLogin::RubySaml::Response.new(read_invalid_response("empty_destination.xml.base64"), {:skip_destination => true}) }
    let(:response_no_status) { OneLogin::RubySaml::Response.new(read_invalid_response("no_status.xml.base64")) }
    let(:response_no_statuscode) { OneLogin::RubySaml::Response.new(read_invalid_response("no_status_code.xml.base64")) }
    let(:response_statuscode_responder) { OneLogin::RubySaml::Response.new(read_invalid_response("status_code_responder.xml.base64")) }
    let(:response_statuscode_responder_and_msg) { OneLogin::RubySaml::Response.new(read_invalid_response("status_code_responer_and_msg.xml.base64")) }
    let(:response_double_statuscode) { OneLogin::RubySaml::Response.new(response_document_double_status_code) }
    let(:response_encrypted_attrs) { OneLogin::RubySaml::Response.new(response_document_encrypted_attrs) }
    let(:response_no_signed_elements) { OneLogin::RubySaml::Response.new(read_invalid_response("no_signature.xml.base64")) }
    let(:response_multiple_signed) { OneLogin::RubySaml::Response.new(read_invalid_response("multiple_signed.xml.base64")) }
    let(:response_audience_self_closed) { OneLogin::RubySaml::Response.new(read_response("response_audience_self_closed_tag.xml.base64")) }
    let(:response_invalid_audience) { OneLogin::RubySaml::Response.new(read_invalid_response("invalid_audience.xml.base64")) }
    let(:response_invalid_signed_element) { OneLogin::RubySaml::Response.new(read_invalid_response("response_invalid_signed_element.xml.base64")) }
    let(:response_invalid_issuer_assertion) { OneLogin::RubySaml::Response.new(read_invalid_response("invalid_issuer_assertion.xml.base64")) }
    let(:response_invalid_issuer_message) { OneLogin::RubySaml::Response.new(read_invalid_response("invalid_issuer_message.xml.base64")) }
    let(:response_no_issuer_response) { OneLogin::RubySaml::Response.new(read_invalid_response("no_issuer_response.xml.base64")) }
    let(:response_no_issuer_assertion) { OneLogin::RubySaml::Response.new(read_invalid_response("no_issuer_assertion.xml.base64")) }
    let(:response_no_nameid) { OneLogin::RubySaml::Response.new(read_invalid_response("no_nameid.xml.base64")) }
    let(:response_empty_nameid) { OneLogin::RubySaml::Response.new(read_invalid_response("empty_nameid.xml.base64")) }
    let(:response_wrong_spnamequalifier) { OneLogin::RubySaml::Response.new(read_invalid_response("wrong_spnamequalifier.xml.base64")) }
    let(:response_duplicated_attributes) { OneLogin::RubySaml::Response.new(read_invalid_response("duplicated_attributes.xml.base64")) }
    let(:response_no_subjectconfirmation_data) { OneLogin::RubySaml::Response.new(read_invalid_response("no_subjectconfirmation_data.xml.base64")) }
    let(:response_no_subjectconfirmation_method) { OneLogin::RubySaml::Response.new(read_invalid_response("no_subjectconfirmation_method.xml.base64")) }
    let(:response_invalid_subjectconfirmation_inresponse) { OneLogin::RubySaml::Response.new(read_invalid_response("invalid_subjectconfirmation_inresponse.xml.base64")) }
    let(:response_invalid_subjectconfirmation_recipient) { OneLogin::RubySaml::Response.new(read_invalid_response("invalid_subjectconfirmation_recipient.xml.base64")) }
    let(:response_invalid_subjectconfirmation_nb) { OneLogin::RubySaml::Response.new(read_invalid_response("invalid_subjectconfirmation_nb.xml.base64")) }
    let(:response_invalid_subjectconfirmation_noa) { OneLogin::RubySaml::Response.new(read_invalid_response("invalid_subjectconfirmation_noa.xml.base64")) }
    let(:response_invalid_signature_position) { OneLogin::RubySaml::Response.new(read_invalid_response("invalid_signature_position.xml.base64")) }
    let(:response_encrypted_nameid) { OneLogin::RubySaml::Response.new(response_document_encrypted_nameid) }

    it "raise an exception when response is initialized with nil" do
      assert_raises(ArgumentError) { OneLogin::RubySaml::Response.new(nil) }
    end

    it "be able to parse a document which contains ampersands" do
      XMLSecurity::SignedDocument.any_instance.stubs(:digests_match?).returns(true)
      OneLogin::RubySaml::Response.any_instance.stubs(:validate_conditions).returns(true)

      ampersands_response = OneLogin::RubySaml::Response.new(ampersands_document)
      ampersands_response.settings = settings
      ampersands_response.settings.idp_cert_fingerprint = 'c51985d947f1be57082025050846eb27f6cab783'

      assert !ampersands_response.is_valid?
      assert_includes ampersands_response.errors, "SAML Response must contain 1 assertion"
    end

    describe "Prevent node text with comment attack (VU#475445)" do
      before do
        @response = OneLogin::RubySaml::Response.new(read_response('response_node_text_attack.xml.base64'))
      end

      it "receives the full NameID when there is an injected comment" do
        assert_equal "support@onelogin.com", @response.name_id
      end

      it "receives the full AttributeValue when there is an injected comment" do
        assert_equal "smith", @response.attributes["surname"]
      end

    end

    describe "Prevent XEE attack" do
      before do
        @response = OneLogin::RubySaml::Response.new(fixture(:attackxee))
      end

      it "false when evil attack vector is present, soft = true" do
        @response.soft = true
        assert !@response.send(:validate_structure)
        assert_includes @response.errors, "Invalid SAML Response. Not match the saml-schema-protocol-2.0.xsd"
      end

      it "raise when evil attack vector is present, soft = false " do
        @response.soft = false

        assert_raises(OneLogin::RubySaml::ValidationError) do
          @response.send(:validate_structure)
        end
      end
    end

    it "adapt namespace" do
      refute_nil response.nameid
      refute_nil response_without_attributes.nameid
      refute_nil response_with_signed_assertion.nameid
    end

    it "default to raw input when a response is not Base64 encoded" do
      decoded  = Base64.decode64(response_document_without_attributes)
      response_from_raw = OneLogin::RubySaml::Response.new(decoded)
      assert response_from_raw.document
    end

    describe "Assertion" do
      it "only retreive an assertion with an ID that matches the signature's reference URI" do
        response_wrapped.stubs(:conditions).returns(nil)
        settings.idp_cert_fingerprint = signature_fingerprint_1
        response_wrapped.settings = settings
        assert_nil response_wrapped.nameid
      end
    end

    describe "#is_valid?" do
      describe "soft = false" do

        before do
          response.soft = false
          response_valid_signed.soft = false
        end

        it "raise when response is initialized with blank data" do
          blank_response = OneLogin::RubySaml::Response.new('')
          blank_response.soft = false
          error_msg = "Blank response"
          assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
            blank_response.is_valid?
          end
          assert_includes blank_response.errors, error_msg
        end

        it "raise when settings have not been set" do
          error_msg = "No settings on response"
          assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
            response.is_valid?
          end
          assert_includes response.errors, error_msg
        end

        it "raise when No fingerprint or certificate on settings" do
          settings.idp_cert_fingerprint = nil
          settings.idp_cert = nil
          settings.idp_cert_multi = nil
          response.settings = settings
          error_msg = "No fingerprint or certificate on settings"
          assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
            response.is_valid?
          end
          assert_includes response.errors, error_msg
        end

        it "raise when signature wrapping attack" do
          response_wrapped.stubs(:conditions).returns(nil)
          response_wrapped.stubs(:validate_subject_confirmation).returns(true)
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_wrapped.settings = settings
          assert !response_wrapped.is_valid?
        end

        it "validate SAML 2.0 XML structure" do
          resp_xml = Base64.decode64(response_document_unsigned).gsub(/emailAddress/,'test')
          response_unsigned_mod = OneLogin::RubySaml::Response.new(Base64.encode64(resp_xml))
          response_unsigned_mod.stubs(:conditions).returns(nil)
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_unsigned_mod.settings = settings
          response_unsigned_mod.soft = false
          assert_raises(OneLogin::RubySaml::ValidationError, 'Digest mismatch') do
            response_unsigned_mod.is_valid?
          end
        end

        it "raise when encountering a condition that prevents the document from being valid" do
          settings.idp_cert_fingerprint = ruby_saml_cert_fingerprint
          response.settings = settings
          response.soft = false
          error_msg = "Current time is on or after NotOnOrAfter condition"
          assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
            response.is_valid?
          end
          assert_includes response.errors[0], error_msg
        end

        it "raise when encountering a SAML Response with bad formatted" do
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_without_attributes.settings = settings
          response_without_attributes.soft = false
          assert_raises(OneLogin::RubySaml::ValidationError) do
            response_without_attributes.is_valid?
          end
        end

        it "raise when the inResponseTo value does not match the Request ID" do
          settings.soft = false
          settings.idp_cert_fingerprint = signature_fingerprint_1
          opts = {}
          opts[:settings] = settings
          opts[:matches_request_id] = "invalid_request_id"
          response_valid_signed = OneLogin::RubySaml::Response.new(response_document_valid_signed, opts)
          error_msg = "The InResponseTo of the Response: _fc4a34b0-7efb-012e-caae-782bcb13bb38, does not match the ID of the AuthNRequest sent by the SP: invalid_request_id"
          assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
            response_valid_signed.is_valid?
          end
          assert_includes response_valid_signed.errors, error_msg
        end

        it "raise when there is no valid audience" do
          settings.idp_cert_fingerprint = signature_fingerprint_1
          settings.issuer = 'invalid'
          response_valid_signed.settings = settings
          response_valid_signed.soft = false
          error_msg = "#{response_valid_signed.settings.issuer} is not a valid audience for this Response - Valid audiences: https://someone.example.com/audience"
          assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
            response_valid_signed.is_valid?
          end
          assert_includes response_valid_signed.errors, error_msg
        end

        it "raise when no ID present in the SAML Response" do
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_no_id.settings = settings
          response_no_id.soft = false
          error_msg = "Missing ID attribute on SAML Response"
          assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
            response_no_id.is_valid?
          end
          assert_includes response_no_id.errors, error_msg
        end

        it "raise when no 2.0 Version present in the SAML Response" do
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_no_version.settings = settings
          response_no_version.soft = false
          error_msg = "Unsupported SAML version"
          assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
            response_no_version.is_valid?
          end
          assert_includes response_no_version.errors, error_msg
        end
      end

      describe "soft = true" do
        before do
          response.soft = true
          response_valid_signed.soft = true
        end

        it "return true when the response is initialized with valid data" do
          response_valid_signed_without_recipient.stubs(:conditions).returns(nil)
          response_valid_signed_without_recipient.settings = settings
          response_valid_signed_without_recipient.settings.idp_cert_fingerprint = ruby_saml_cert_fingerprint
          assert response_valid_signed_without_recipient.is_valid?
          assert_empty response_valid_signed_without_recipient.errors
        end

        it "return true when the response is initialized with valid data and using certificate instead of fingerprint" do
          response_valid_signed_without_recipient.stubs(:conditions).returns(nil)
          response_valid_signed_without_recipient.settings = settings
          response_valid_signed_without_recipient.settings.idp_cert = ruby_saml_cert_text
          assert response_valid_signed_without_recipient.is_valid?
          assert_empty response_valid_signed_without_recipient.errors
        end

        it "return false when response is initialized with blank data" do
          blank_response = OneLogin::RubySaml::Response.new('')
          blank_response.soft = true
          assert !blank_response.is_valid?
          assert_includes blank_response.errors, "Blank response"
        end

        it "return false if settings have not been set" do
          assert !response.is_valid?
          assert_includes response.errors, "No settings on response"
        end

        it "return false if fingerprint or certificate not been set on settings" do
          response.settings = settings
          assert !response.is_valid?
          assert_includes response.errors, "No fingerprint or certificate on settings"
        end

        it "should be idempotent when the response is initialized with invalid data" do
          response_unsigned.stubs(:conditions).returns(nil)
          response_unsigned.settings = settings
          assert !response_unsigned.is_valid?
          assert !response_unsigned.is_valid?
        end

        it "should be idempotent when the response is initialized with valid data" do
          response_valid_signed_without_recipient.stubs(:conditions).returns(nil)
          response_valid_signed_without_recipient.settings = settings
          response_valid_signed_without_recipient.settings.idp_cert_fingerprint = ruby_saml_cert_fingerprint
          assert response_valid_signed_without_recipient.is_valid?
          assert response_valid_signed_without_recipient.is_valid?
        end

        it "not allow signature wrapping attack" do
          response_wrapped.stubs(:conditions).returns(nil)
          response_wrapped.stubs(:validate_subject_confirmation).returns(true)
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_wrapped.settings = settings
          assert !response_wrapped.is_valid?
        end

        it "support dynamic namespace resolution on signature elements" do
          no_signature_response = OneLogin::RubySaml::Response.new(fixture("no_signature_ns.xml"))
          no_signature_response.stubs(:conditions).returns(nil)
          no_signature_response.stubs(:validate_subject_confirmation).returns(true)
          no_signature_response.settings = settings
          no_signature_response.settings.idp_cert_fingerprint = "28:74:9B:E8:1F:E8:10:9C:A8:7C:A9:C3:E3:C5:01:6C:92:1C:B4:BA"
          XMLSecurity::SignedDocument.any_instance.expects(:validate_signature).returns(true)
          assert no_signature_response.is_valid?
        end

        it "validate ADFS assertions" do
          adfs_response = OneLogin::RubySaml::Response.new(fixture(:adfs_response_sha256))
          adfs_response.stubs(:conditions).returns(nil)
          adfs_response.stubs(:validate_subject_confirmation).returns(true)
          settings.idp_cert_fingerprint = "28:74:9B:E8:1F:E8:10:9C:A8:7C:A9:C3:E3:C5:01:6C:92:1C:B4:BA"
          adfs_response.settings = settings
          adfs_response.soft = true
          assert adfs_response.is_valid?
        end

        it "validate SAML 2.0 XML structure" do
          resp_xml = Base64.decode64(response_document_unsigned).gsub(/emailAddress/,'test')
          response_unsigned_mod = OneLogin::RubySaml::Response.new(Base64.encode64(resp_xml))
          response_unsigned_mod.stubs(:conditions).returns(nil)
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_unsigned_mod.settings = settings
          response_unsigned_mod.soft = true
          assert !response_unsigned_mod.is_valid?
        end

        it "return false when encountering a condition that prevents the document from being valid" do
          settings.idp_cert_fingerprint = ruby_saml_cert_fingerprint
          response.settings = settings
          error_msg = "Current time is on or after NotOnOrAfter condition"
          assert !response.is_valid?
          assert_includes response.errors[0], "Current time is on or after NotOnOrAfter condition"
        end

        it "return false when encountering a SAML Response with bad formatted" do
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_without_attributes.settings = settings
          response_without_attributes.soft = true
          error_msg = "Invalid SAML Response. Not match the saml-schema-protocol-2.0.xsd"
          response_without_attributes.is_valid?
          assert_includes response_without_attributes.errors, error_msg
        end

        it "return false when the inResponseTo value does not match the Request ID" do
          settings.soft = true
          settings.idp_cert_fingerprint = signature_fingerprint_1
          opts = {}
          opts[:settings] = settings
          opts[:matches_request_id] = "invalid_request_id"
          response_valid_signed = OneLogin::RubySaml::Response.new(response_document_valid_signed, opts)
          response_valid_signed.is_valid?
          assert_includes response_valid_signed.errors, "The InResponseTo of the Response: _fc4a34b0-7efb-012e-caae-782bcb13bb38, does not match the ID of the AuthNRequest sent by the SP: invalid_request_id"
        end

        it "return false when there is no valid audience" do
          settings.idp_cert_fingerprint = signature_fingerprint_1
          settings.issuer = 'invalid'
          response_valid_signed.settings = settings
          response_valid_signed.is_valid?
          assert_includes response_valid_signed.errors, "#{response_valid_signed.settings.issuer} is not a valid audience for this Response - Valid audiences: https://someone.example.com/audience"
        end

        it "return false when no ID present in the SAML Response" do
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_no_id.settings = settings
          response_no_id.soft = true
          response_no_id.is_valid?
          assert_includes response_no_id.errors, "Missing ID attribute on SAML Response"
        end

        it "return false when no 2.0 Version present in the SAML Response" do
          settings.idp_cert_fingerprint = signature_fingerprint_1
          response_no_version.settings = settings
          response_no_version.soft = true
          error_msg = "Unsupported SAML version"
          response_no_version.is_valid?
          assert_includes response_no_version.errors, "Unsupported SAML version"
        end

        it "return true when a nil URI is given in the ds:Reference" do
          settings.idp_cert = ruby_saml_cert_text
          settings.assertion_consumer_service_url = "http://localhost:9001/v1/users/authorize/saml"
          response_without_reference_uri.settings = settings
          response_without_reference_uri.stubs(:conditions).returns(nil)
          response_without_reference_uri.is_valid?
          assert_empty response_without_reference_uri.errors
          assert 'saml@user.com', response_without_reference_uri.attributes['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']
        end

        it "collect errors when collect_errors=true" do
          settings.idp_cert = ruby_saml_cert_text
          settings.issuer = 'invalid'
          response_invalid_subjectconfirmation_recipient.settings = settings
          collect_errors = true
          response_invalid_subjectconfirmation_recipient.is_valid?(collect_errors)
          assert_includes response_invalid_subjectconfirmation_recipient.errors, "invalid is not a valid audience for this Response - Valid audiences: http://stuff.com/endpoints/metadata.php"
          assert_includes response_invalid_subjectconfirmation_recipient.errors, "Invalid Signature on SAML Response"
        end
      end
    end

    describe "#validate_audience" do
      it "return true when the audience is valid" do
        response.settings = settings
        response.settings.issuer = '{audience}'
        assert response.send(:validate_audience)
        assert_empty response.errors
      end

      it "return true when the audience is self closing" do
        response_audience_self_closed.settings = settings
        response_audience_self_closed.settings.issuer = '{audience}'
        assert response_audience_self_closed.send(:validate_audience)
        assert_empty response_audience_self_closed.errors
      end

      it "return false when the audience is valid" do
        response.settings = settings
        response.settings.issuer = 'invalid_audience'
        assert !response.send(:validate_audience)
        assert_includes response.errors, "#{response.settings.issuer} is not a valid audience for this Response - Valid audiences: {audience}"
      end
    end

    describe "#validate_destination" do
      it "return true when the destination of the SAML Response matches the assertion consumer service url" do
        response.settings = settings
        assert response.send(:validate_destination)
        assert_empty response.errors
      end

      it "return false when the destination of the SAML Response does not match the assertion consumer service url" do
        response.settings = settings
        response.settings.assertion_consumer_service_url = 'invalid_acs'
        assert !response.send(:validate_destination)
        assert_includes response.errors, "The response was received at #{response.destination} instead of #{response.settings.assertion_consumer_service_url}"
      end

      it "return false when the destination of the SAML Response is empty" do
        response_empty_destination.settings = settings
        assert !response_empty_destination.send(:validate_destination)
        assert_includes response_empty_destination.errors, "The response has an empty Destination value"
      end

      it "return true when the destination of the SAML Response is empty but skip_destination option is used" do
        response_empty_destination_with_skip.settings = settings
        assert response_empty_destination_with_skip.send(:validate_destination)
        assert_empty response_empty_destination.errors
      end

      it "returns true on a case insensitive match on the domain" do
        response_valid_signed_without_x509certificate.settings = settings
        response_valid_signed_without_x509certificate.settings.assertion_consumer_service_url = 'http://APP.muDa.no/sso/consume'
        assert response_valid_signed_without_x509certificate.send(:validate_destination)
        assert_empty response_valid_signed_without_x509certificate.errors
      end

      it "returns true on a case insensitive match on the scheme" do
        response_valid_signed_without_x509certificate.settings = settings
        response_valid_signed_without_x509certificate.settings.assertion_consumer_service_url = 'HTTP://app.muda.no/sso/consume'
        assert response_valid_signed_without_x509certificate.send(:validate_destination)
        assert_empty response_valid_signed_without_x509certificate.errors
      end

      it "returns false on a case insenstive match on the path" do
        response_valid_signed_without_x509certificate.settings = settings
        response_valid_signed_without_x509certificate.settings.assertion_consumer_service_url = 'http://app.muda.no/SSO/consume'
        assert !response_valid_signed_without_x509certificate.send(:validate_destination)
        assert_includes response_valid_signed_without_x509certificate.errors, "The response was received at #{response_valid_signed_without_x509certificate.destination} instead of #{response_valid_signed_without_x509certificate.settings.assertion_consumer_service_url}"
      end

      it "returns true if it can't parse out a full URI." do
        response_valid_signed_without_x509certificate.settings = settings
        response_valid_signed_without_x509certificate.settings.assertion_consumer_service_url = 'presenter'
        assert !response_valid_signed_without_x509certificate.send(:validate_destination)
        assert_includes response_valid_signed_without_x509certificate.errors, "The response was received at #{response_valid_signed_without_x509certificate.destination} instead of #{response_valid_signed_without_x509certificate.settings.assertion_consumer_service_url}"
      end
    end

    describe "#validate_issuer" do
      it "return true when the issuer of the Message/Assertion matches the IdP entityId" do
        response_valid_signed.settings = settings
        assert response_valid_signed.send(:validate_issuer)

        response_valid_signed.settings.idp_entity_id = 'https://app.onelogin.com/saml2'
        assert response_valid_signed.send(:validate_issuer)
      end

      it "return false when the issuer of the Message does not match the IdP entityId" do
        response_invalid_issuer_message.settings = settings
        response_invalid_issuer_message.settings.idp_entity_id = 'http://idp.example.com/'
        assert !response_invalid_issuer_message.send(:validate_issuer)
        assert_includes response_invalid_issuer_message.errors, "Doesn't match the issuer, expected: <#{response_invalid_issuer_message.settings.idp_entity_id}>, but was: <http://invalid.issuer.example.com/>"
      end

      it "return false when the issuer of the Assertion does not match the IdP entityId" do
        response_invalid_issuer_assertion.settings = settings
        response_invalid_issuer_assertion.settings.idp_entity_id = 'http://idp.example.com/'
        assert !response_invalid_issuer_assertion.send(:validate_issuer)
        assert_includes response_invalid_issuer_assertion.errors, "Doesn't match the issuer, expected: <#{response_invalid_issuer_assertion.settings.idp_entity_id}>, but was: <http://invalid.issuer.example.com/>"
      end
    end

    describe "#validate_num_assertion" do
      it "return true when SAML Response contains 1 assertion" do
        assert response.send(:validate_num_assertion)
        assert_empty response.errors
      end

      it "return false when no 2.0 Version present in the SAML Response" do
        assert !response_multi_assertion.send(:validate_num_assertion)
        assert_includes response_multi_assertion.errors, "SAML Response must contain 1 assertion"
      end
    end

    describe "validate_success_status" do
      it "return true when the status is 'Success'" do
        assert response.send(:validate_success_status)
        assert_empty response.errors
      end

      it "return false when no Status provided" do
        assert !response_no_status.send(:validate_success_status)
        assert_includes response_no_status.errors, "The status code of the Response was not Success"
      end

      it "return false when no StatusCode provided" do
        assert !response_no_statuscode.send(:validate_success_status)
        assert_includes response_no_statuscode.errors, "The status code of the Response was not Success"
      end

      it "return false when the status is not 'Success'" do
        assert !response_statuscode_responder.send(:validate_success_status)
        assert_includes response_statuscode_responder.errors, "The status code of the Response was not Success, was Responder"
      end

      it "return false when the status is not 'Success', and shows the StatusMessage" do
        assert !response_statuscode_responder_and_msg.send(:validate_success_status)
        assert_includes response_statuscode_responder_and_msg.errors, "The status code of the Response was not Success, was Responder -> something_is_wrong"
      end

      it "return false when the status is not 'Success'" do
        assert !response_double_statuscode.send(:validate_success_status)
        assert_includes response_double_statuscode.errors, "The status code of the Response was not Success, was Requester => UnsupportedBinding"
      end
    end

    describe "#validate_structure" do
      it "return true when encountering a wellformed SAML Response" do
        assert response.send(:validate_structure)
        assert_empty response.errors
      end

      it "return false when encountering a mailformed element that prevents the document from being valid" do
        response_without_attributes.soft = true
        response_without_attributes.send(:validate_structure)
        assert response_without_attributes.errors.include? "Invalid SAML Response. Not match the saml-schema-protocol-2.0.xsd"
      end

      it "raise when encountering a mailformed element that prevents the document from being valid" do
        response_without_attributes.soft = false
        assert_raises(OneLogin::RubySaml::ValidationError) {
          response_without_attributes.send(:validate_structure)
        }
      end
    end

    describe "#validate_in_response_to" do
      it "return true when the inResponseTo value matches the Request ID" do
        response = OneLogin::RubySaml::Response.new(response_document_valid_signed, :settings => settings, :matches_request_id => "_fc4a34b0-7efb-012e-caae-782bcb13bb38")
        assert response.send(:validate_in_response_to)
        assert_empty response.errors
      end

      it "return true when no Request ID is provided for checking" do
        response = OneLogin::RubySaml::Response.new(response_document_valid_signed, :settings => settings)
        assert response.send(:validate_in_response_to)
        assert_empty response.errors
      end

      it "return false when the inResponseTo value does not match the Request ID" do
        response = OneLogin::RubySaml::Response.new(response_document_valid_signed, :settings => settings, :matches_request_id => "invalid_request_id")
        assert !response.send(:validate_in_response_to)
        assert_includes response.errors, "The InResponseTo of the Response: _fc4a34b0-7efb-012e-caae-782bcb13bb38, does not match the ID of the AuthNRequest sent by the SP: invalid_request_id"
      end
    end

    describe "#validate_audience" do
      it "return true when the audience is valid" do
        response_valid_signed.settings = settings
        response_valid_signed.settings.issuer = "https://someone.example.com/audience"
        assert response_valid_signed.send(:validate_audience)
        assert_empty response_valid_signed.errors
      end

      it "return true when there is not issuer defined" do
        response_valid_signed.settings = settings
        response_valid_signed.settings.issuer = nil
        assert response_valid_signed.send(:validate_audience)
        assert_empty response_valid_signed.errors
      end

      it "return false when there is no valid audience" do
        response_invalid_audience.settings = settings
        response_invalid_audience.settings.issuer = "https://invalid.example.com/audience"
        assert !response_invalid_audience.send(:validate_audience)
        assert_includes response_invalid_audience.errors, "#{response_invalid_audience.settings.issuer} is not a valid audience for this Response - Valid audiences: http://invalid.audience.com"
      end
    end

    describe "#validate_issuer" do
      it "return true when the issuer of the Message/Assertion matches the IdP entityId or it was empty" do
        response_valid_signed.settings = settings
        assert response_valid_signed.send(:validate_issuer)
        assert_empty response_valid_signed.errors

        response_valid_signed.settings.idp_entity_id = 'https://app.onelogin.com/saml2'
        assert response_valid_signed.send(:validate_issuer)
        assert_empty response_valid_signed.errors
      end

      it "return false when the issuer of the Message does not match the IdP entityId" do
        response_invalid_issuer_message.settings = settings
        response_invalid_issuer_message.settings.idp_entity_id = 'http://idp.example.com/'
        assert !response_invalid_issuer_message.send(:validate_issuer)
        assert_includes response_invalid_issuer_message.errors, "Doesn't match the issuer, expected: <#{response_invalid_issuer_message.settings.idp_entity_id}>, but was: <http://invalid.issuer.example.com/>"
      end

      it "return false when the issuer of the Assertion does not match the IdP entityId" do
        response_invalid_issuer_assertion.settings = settings
        response_invalid_issuer_assertion.settings.idp_entity_id = 'http://idp.example.com/'
        assert !response_invalid_issuer_assertion.send(:validate_issuer)
        assert_includes response_invalid_issuer_assertion.errors, "Doesn't match the issuer, expected: <#{response_invalid_issuer_assertion.settings.idp_entity_id}>, but was: <http://invalid.issuer.example.com/>"
      end

      it "return false when the no issuer at the Response" do
        response_no_issuer_response.settings = settings
        response_no_issuer_response.settings.idp_entity_id = 'http://idp.example.com/'
        assert !response_no_issuer_response.send(:validate_issuer)
        assert_includes response_no_issuer_response.errors, "Issuer of the Response not found or multiple."
      end

      it "return false when the no issuer at the Assertion" do
        response_no_issuer_assertion.settings = settings
        response_no_issuer_assertion.settings.idp_entity_id = 'http://idp.example.com/'
        assert !response_no_issuer_assertion.send(:validate_issuer)
        assert_includes response_no_issuer_assertion.errors, "Issuer of the Assertion not found or multiple."
      end
    end

    describe "#validate_subject_confirmation" do
      it "return true when valid subject confirmation" do
        response_valid_signed.settings = settings
        response_valid_signed.settings.assertion_consumer_service_url = 'recipient'
        assert response_valid_signed.send(:validate_subject_confirmation)
        assert_empty response_valid_signed.errors
      end

      it "return false when no subject confirmation data" do
        response_no_subjectconfirmation_data.settings = settings
        assert !response_no_subjectconfirmation_data.send(:validate_subject_confirmation)
        assert_includes response_no_subjectconfirmation_data.errors, "A valid SubjectConfirmation was not found on this Response"
      end

      it "return false when no valid subject confirmation method" do
        response_no_subjectconfirmation_method.settings = settings
        assert !response_no_subjectconfirmation_method.send(:validate_subject_confirmation)
        assert_includes response_no_subjectconfirmation_method.errors, "A valid SubjectConfirmation was not found on this Response"
      end

      it "return false when invalid inresponse" do
        response_invalid_subjectconfirmation_inresponse.settings = settings
        assert !response_invalid_subjectconfirmation_inresponse.send(:validate_subject_confirmation)
        assert_includes response_invalid_subjectconfirmation_inresponse.errors, "A valid SubjectConfirmation was not found on this Response"
      end

      it "return false when invalid NotBefore" do
        response_invalid_subjectconfirmation_nb.settings = settings
        assert !response_invalid_subjectconfirmation_nb.send(:validate_subject_confirmation)
        assert_includes response_invalid_subjectconfirmation_nb.errors, "A valid SubjectConfirmation was not found on this Response"
      end

      it "return false when invalid NotOnOrAfter" do
        response_invalid_subjectconfirmation_noa.settings = settings
        assert !response_invalid_subjectconfirmation_noa.send(:validate_subject_confirmation)
        assert_includes response_invalid_subjectconfirmation_noa.errors, "A valid SubjectConfirmation was not found on this Response"
      end

      it "return true when valid subject confirmation recipient" do
        response_valid_signed.settings = settings
        response_valid_signed.settings.assertion_consumer_service_url = 'recipient'
        assert response_valid_signed.send(:validate_subject_confirmation)
        assert_empty response_valid_signed.errors
        assert_empty response_valid_signed.errors
      end

      it "return false when invalid subject confirmation recipient" do
        response_valid_signed.settings = settings
        response_valid_signed.settings.assertion_consumer_service_url = 'not-the-recipient'
        assert !response_valid_signed.send(:validate_subject_confirmation)
        assert_includes response_valid_signed.errors, "A valid SubjectConfirmation was not found on this Response"
      end

      it "return false when invalid subject confirmation recipient, but skipping the check(default)" do
        response_valid_signed_without_recipient.settings = settings
        response_valid_signed_without_recipient.settings.assertion_consumer_service_url = 'not-the-recipient'
        assert response_valid_signed_without_recipient.send(:validate_subject_confirmation)
        assert_empty response_valid_signed_without_recipient.errors
      end

      it "return true when the skip_subject_confirmation option is passed and the subject confirmation is valid" do
        opts = {}
        opts[:skip_subject_confirmation] = true
        response_with_skip = OneLogin::RubySaml::Response.new(response_document_valid_signed, opts)
        response_with_skip.settings = settings
        response_with_skip.settings.assertion_consumer_service_url = 'recipient'
        Time.expects(:now).times(0) # ensures the test isn't run and thus Time.now.utc is never called within the test
        assert response_with_skip.send(:validate_subject_confirmation)
        assert_empty response_with_skip.errors
      end

      it "return true when the skip_subject_confirmation option is passed and the response has an invalid subject confirmation" do
        opts = {}
        opts[:skip_subject_confirmation] = true
        response_with_skip = OneLogin::RubySaml::Response.new(read_invalid_response("invalid_subjectconfirmation_noa.xml.base64"), opts)
        response_with_skip.settings = settings
        Time.expects(:now).times(0) # ensures the test isn't run and thus Time.now.utc is never called within the test
        assert response_with_skip.send(:validate_subject_confirmation)
        assert_empty response_with_skip.errors
      end
    end

    describe "#validate_session_expiration" do
      it "return true when the session has not expired" do
        response_valid_signed.settings = settings
        assert response_valid_signed.send(:validate_session_expiration)
        assert_empty response_valid_signed.errors
      end

      it "return false when the session has expired" do
        response.settings = settings
        assert !response.send(:validate_session_expiration)
        assert_includes response.errors, "The attributes have expired, based on the SessionNotOnOrAfter of the AttributeStatement of this Response"
      end

      it "returns true when the session has expired, but is still within the allowed_clock_drift" do
        drift = (Time.now - Time.parse("2010-11-19T21:57:37Z")) * 60 # seconds ago that this assertion expired
        drift += 10 # add a buffer of 10 seconds to make sure the test passes
        opts = {}
        opts[:allowed_clock_drift] = drift

        response_with_drift = OneLogin::RubySaml::Response.new(response_document_without_recipient, opts)
        response_with_drift.settings = settings
        assert response_with_drift.send(:validate_session_expiration)
        assert_empty response_with_drift.errors
      end
    end

    describe "#validate_signature" do
      it "return true when the signature is valid" do
        settings.idp_cert_fingerprint = ruby_saml_cert_fingerprint
        response_valid_signed.settings = settings
        assert response_valid_signed.send(:validate_signature)
        assert_empty response_valid_signed.errors
      end

      it "return true when the signature is valid and ds namespace is at the root" do
        settings.idp_cert_fingerprint = '5614657ab692b960480389723a36446a5fe1f7ec'
        response_with_ds_namespace_at_the_root.settings = settings
        assert response_with_ds_namespace_at_the_root.send(:validate_signature)
        assert_empty response_with_ds_namespace_at_the_root.errors
      end

      it "return true when the signature is valid and fingerprint provided" do
        settings.idp_cert_fingerprint = '49:EC:3F:A4:71:8A:1E:C9:DB:70:A7:CC:33:36:96:F0:48:8C:4E:DA'
        xml = 'PHNhbWxwOlJlc3BvbnNlIHhtbG5zOnNhbWxwPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6cHJvdG9jb2wiIERlc3RpbmF0aW9uPSJodHRwczovL2NvZGVycGFkLmlvL3NhbWwvYWNzIiBJRD0iXzEwOGE1ZTg0MDllYzRjZjlhY2QxYzQ2OWU5ZDcxNGFkIiBJblJlc3BvbnNlVG89Il80ZmZmYWE2MC02OTZiLTAxMzMtMzg4Ni0wMjQxZjY1YzA2OTMiIElzc3VlSW5zdGFudD0iMjAxNS0xMS0wOVQyMzo1NTo0M1oiIFZlcnNpb249IjIuMCI+PHNhbWw6SXNzdWVyIHhtbG5zOnNhbWw9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDphc3NlcnRpb24iPmh0dHBzOi8vbG9naW4uaHVsdS5jb208L3NhbWw6SXNzdWVyPjxkczpTaWduYXR1cmUgeG1sbnM6ZHM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyMiPjxkczpTaWduZWRJbmZvPjxkczpDYW5vbmljYWxpemF0aW9uTWV0aG9kIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMS8xMC94bWwtZXhjLWMxNG4jIj48L2RzOkNhbm9uaWNhbGl6YXRpb25NZXRob2Q+PGRzOlNpZ25hdHVyZU1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNyc2Etc2hhMSI+PC9kczpTaWduYXR1cmVNZXRob2Q+PGRzOlJlZmVyZW5jZSBVUkk9IiNfMTA4YTVlODQwOWVjNGNmOWFjZDFjNDY5ZTlkNzE0YWQiPjxkczpUcmFuc2Zvcm1zPjxkczpUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjZW52ZWxvcGVkLXNpZ25hdHVyZSI+PC9kczpUcmFuc2Zvcm0+PGRzOlRyYW5zZm9ybSBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvMTAveG1sLWV4Yy1jMTRuIyI+PC9kczpUcmFuc2Zvcm0+PC9kczpUcmFuc2Zvcm1zPjxkczpEaWdlc3RNZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjc2hhMSI+PC9kczpEaWdlc3RNZXRob2Q+PGRzOkRpZ2VzdFZhbHVlPm9sQllXbTQyRi9oZm0xdHJYTHk2a3V6MXlMUT08L2RzOkRpZ2VzdFZhbHVlPjwvZHM6UmVmZXJlbmNlPjwvZHM6U2lnbmVkSW5mbz48ZHM6U2lnbmF0dXJlVmFsdWU+dXNRTmY5WGpKTDRlOXVucnVCdWViSnQ3R0tXM2hJUk9teWVqTm1NMHM4WFhlWHN3WHc4U3ZCZi8zeDNNWEpkWnpNV0pOM3ExN2tGWHN2bTVna1JzbkE9PTwvZHM6U2lnbmF0dXJlVmFsdWU+PGRzOktleUluZm8+PGRzOlg1MDlEYXRhPjxkczpYNTA5Q2VydGlmaWNhdGU+TUlJQ1FEQ0NBZXFnQXdJQkFnSUpBSVZOdzVLRzR1aTFNQTBHQ1NxR1NJYjNEUUVCQlFVQU1Fd3hDekFKQmdOVkJBWVRBa2RDTVJJd0VBWURWUVFJRXdsQ1pYSnJjMmhwY21VeEVEQU9CZ05WQkFjVEIwNWxkMkoxY25reEZ6QVZCZ05WQkFvVERrMTVJRU52YlhCaGJua2dUSFJrTUI0WERURXlNVEF5TlRBMk1qY3pORm9YRFRJeU1UQXlNekEyTWpjek5Gb3dUREVMTUFrR0ExVUVCaE1DUjBJeEVqQVFCZ05WQkFnVENVSmxjbXR6YUdseVpURVFNQTRHQTFVRUJ4TUhUbVYzWW5WeWVURVhNQlVHQTFVRUNoTU9UWGtnUTI5dGNHRnVlU0JNZEdRd1hEQU5CZ2txaGtpRzl3MEJBUUVGQUFOTEFEQklBa0VBd1NOL2dpMzNSbXBBUW9MUWo3UDZ6QW5OVDBSbjdiakMzMjNuM3ExT25mdm52UjBmUWp2TnQ3ckRrQTVBdjVRbk02VjRZVU5Vbk1mYk9RcTBXTGJMU3dJREFRQUJvNEd1TUlHck1CMEdBMVVkRGdRV0JCUWZJSDFvZkJWcHNSQWNJTUsyaGJsN25nTVRZREI4QmdOVkhTTUVkVEJ6Z0JRZklIMW9mQlZwc1JBY0lNSzJoYmw3bmdNVFlLRlFwRTR3VERFTE1Ba0dBMVVFQmhNQ1IwSXhFakFRQmdOVkJBZ1RDVUpsY210emFHbHlaVEVRTUE0R0ExVUVCeE1IVG1WM1luVnllVEVYTUJVR0ExVUVDaE1PVFhrZ1EyOXRjR0Z1ZVNCTWRHU0NDUUNGVGNPU2h1TG90VEFNQmdOVkhSTUVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJCUVVBQTBFQXFvZ1YzdVBjbEtYRG1EWk1UN3ZsUFl4TEFxQ0dIWnRsQ3h6NGhNNEtTdGxEMi9HTmMxWGlMYjFoL0swQ0pMRG9zckVJYm0zd2lPMk12VEVSclZZU01RPT08L2RzOlg1MDlDZXJ0aWZpY2F0ZT48L2RzOlg1MDlEYXRhPjwvZHM6S2V5SW5mbz48L2RzOlNpZ25hdHVyZT48c2FtbHA6U3RhdHVzPjxzYW1scDpTdGF0dXNDb2RlIFZhbHVlPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6c3RhdHVzOlN1Y2Nlc3MiPjwvc2FtbHA6U3RhdHVzQ29kZT48L3NhbWxwOlN0YXR1cz48c2FtbDpBc3NlcnRpb24geG1sbnM6c2FtbD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmFzc2VydGlvbiIgSUQ9Il8wMTg4MmRhOTM2OTQ0ZDFlYTZlZmY0NDA2NTc2MzFiNSIgSXNzdWVJbnN0YW50PSIyMDE1LTExLTA5VDIzOjU1OjQzWiIgVmVyc2lvbj0iMi4wIj48c2FtbDpJc3N1ZXI+aHR0cHM6Ly9sb2dpbi5odWx1LmNvbTwvc2FtbDpJc3N1ZXI+PGRzOlNpZ25hdHVyZSB4bWxuczpkcz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnIyI+PGRzOlNpZ25lZEluZm8+PGRzOkNhbm9uaWNhbGl6YXRpb25NZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzEwL3htbC1leGMtYzE0biMiPjwvZHM6Q2Fub25pY2FsaXphdGlvbk1ldGhvZD48ZHM6U2lnbmF0dXJlTWV0aG9kIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnI3JzYS1zaGExIj48L2RzOlNpZ25hdHVyZU1ldGhvZD48ZHM6UmVmZXJlbmNlIFVSST0iI18wMTg4MmRhOTM2OTQ0ZDFlYTZlZmY0NDA2NTc2MzFiNSI+PGRzOlRyYW5zZm9ybXM+PGRzOlRyYW5zZm9ybSBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNlbnZlbG9wZWQtc2lnbmF0dXJlIj48L2RzOlRyYW5zZm9ybT48ZHM6VHJhbnNmb3JtIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMS8xMC94bWwtZXhjLWMxNG4jIj48L2RzOlRyYW5zZm9ybT48L2RzOlRyYW5zZm9ybXM+PGRzOkRpZ2VzdE1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNzaGExIj48L2RzOkRpZ2VzdE1ldGhvZD48ZHM6RGlnZXN0VmFsdWU+cmo2YzhucC9BUmV0ZkJ1dWVOSzNPS0xDYnowPTwvZHM6RGlnZXN0VmFsdWU+PC9kczpSZWZlcmVuY2U+PC9kczpTaWduZWRJbmZvPjxkczpTaWduYXR1cmVWYWx1ZT5hR05FemZHM1dLcExKc2ZLRGJSNmpva2d6OEFnZ0FIRVVESEZyd0dsTHVQeWpyNEl3M09NcFNkV2gyL01YK1F3M1dPTk5mNHJNalh5TGVZSFJIVGpMQT09PC9kczpTaWduYXR1cmVWYWx1ZT48ZHM6S2V5SW5mbz48ZHM6WDUwOURhdGE+PGRzOlg1MDlDZXJ0aWZpY2F0ZT5NSUlDUURDQ0FlcWdBd0lCQWdJSkFJVk53NUtHNHVpMU1BMEdDU3FHU0liM0RRRUJCUVVBTUV3eEN6QUpCZ05WQkFZVEFrZENNUkl3RUFZRFZRUUlFd2xDWlhKcmMyaHBjbVV4RURBT0JnTlZCQWNUQjA1bGQySjFjbmt4RnpBVkJnTlZCQW9URGsxNUlFTnZiWEJoYm5rZ1RIUmtNQjRYRFRFeU1UQXlOVEEyTWpjek5Gb1hEVEl5TVRBeU16QTJNamN6TkZvd1RERUxNQWtHQTFVRUJoTUNSMEl4RWpBUUJnTlZCQWdUQ1VKbGNtdHphR2x5WlRFUU1BNEdBMVVFQnhNSFRtVjNZblZ5ZVRFWE1CVUdBMVVFQ2hNT1RYa2dRMjl0Y0dGdWVTQk1kR1F3WERBTkJna3Foa2lHOXcwQkFRRUZBQU5MQURCSUFrRUF3U04vZ2kzM1JtcEFRb0xRajdQNnpBbk5UMFJuN2JqQzMyM24zcTFPbmZ2bnZSMGZRanZOdDdyRGtBNUF2NVFuTTZWNFlVTlVuTWZiT1FxMFdMYkxTd0lEQVFBQm80R3VNSUdyTUIwR0ExVWREZ1FXQkJRZklIMW9mQlZwc1JBY0lNSzJoYmw3bmdNVFlEQjhCZ05WSFNNRWRUQnpnQlFmSUgxb2ZCVnBzUkFjSU1LMmhibDduZ01UWUtGUXBFNHdUREVMTUFrR0ExVUVCaE1DUjBJeEVqQVFCZ05WQkFnVENVSmxjbXR6YUdseVpURVFNQTRHQTFVRUJ4TUhUbVYzWW5WeWVURVhNQlVHQTFVRUNoTU9UWGtnUTI5dGNHRnVlU0JNZEdTQ0NRQ0ZUY09TaHVMb3RUQU1CZ05WSFJNRUJUQURBUUgvTUEwR0NTcUdTSWIzRFFFQkJRVUFBMEVBcW9nVjN1UGNsS1hEbURaTVQ3dmxQWXhMQXFDR0hadGxDeHo0aE00S1N0bEQyL0dOYzFYaUxiMWgvSzBDSkxEb3NyRUlibTN3aU8yTXZURVJyVllTTVE9PTwvZHM6WDUwOUNlcnRpZmljYXRlPjwvZHM6WDUwOURhdGE+PC9kczpLZXlJbmZvPjwvZHM6U2lnbmF0dXJlPjxzYW1sOlN1YmplY3Q+PHNhbWw6TmFtZUlEIEZvcm1hdD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6MS4xOm5hbWVpZC1mb3JtYXQ6ZW1haWxBZGRyZXNzIiBTUE5hbWVRdWFsaWZpZXI9Imh0dHBzOi8vY29kZXJwYWQuaW8iPm1hdHQuanVyaWtAaHVsdS5jb208L3NhbWw6TmFtZUlEPjxzYW1sOlN1YmplY3RDb25maXJtYXRpb24gTWV0aG9kPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6Y206YmVhcmVyIj48c2FtbDpTdWJqZWN0Q29uZmlybWF0aW9uRGF0YSBJblJlc3BvbnNlVG89Il80ZmZmYWE2MC02OTZiLTAxMzMtMzg4Ni0wMjQxZjY1YzA2OTMiIE5vdE9uT3JBZnRlcj0iMjAxNS0xMS0xMFQwMDoxMDo0M1oiIFJlY2lwaWVudD0iaHR0cHM6Ly9jb2RlcnBhZC5pby9zYW1sL2FjcyI+PC9zYW1sOlN1YmplY3RDb25maXJtYXRpb25EYXRhPjwvc2FtbDpTdWJqZWN0Q29uZmlybWF0aW9uPjwvc2FtbDpTdWJqZWN0PjxzYW1sOkNvbmRpdGlvbnMgTm90QmVmb3JlPSIyMDE1LTExLTA5VDIyOjU1OjQzWiIgTm90T25PckFmdGVyPSIyMDE1LTExLTEwVDAwOjEwOjQzWiI+PHNhbWw6QXVkaWVuY2VSZXN0cmljdGlvbj48c2FtbDpBdWRpZW5jZT5odHRwczovL2NvZGVycGFkLmlvPC9zYW1sOkF1ZGllbmNlPjwvc2FtbDpBdWRpZW5jZVJlc3RyaWN0aW9uPjwvc2FtbDpDb25kaXRpb25zPjxzYW1sOkF1dGhuU3RhdGVtZW50IEF1dGhuSW5zdGFudD0iMjAxNS0xMS0wOVQyMzo1NTo0M1oiPjxzYW1sOkF1dGhuQ29udGV4dD48c2FtbDpBdXRobkNvbnRleHRDbGFzc1JlZj51cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YWM6Y2xhc3NlczpQYXNzd29yZDwvc2FtbDpBdXRobkNvbnRleHRDbGFzc1JlZj48L3NhbWw6QXV0aG5Db250ZXh0Pjwvc2FtbDpBdXRoblN0YXRlbWVudD48c2FtbDpBdHRyaWJ1dGVTdGF0ZW1lbnQ+PHNhbWw6QXR0cmlidXRlIE5hbWU9IkdpdmVuLW5hbWUiPjxzYW1sOkF0dHJpYnV0ZVZhbHVlPk1hdHQ8L3NhbWw6QXR0cmlidXRlVmFsdWU+PC9zYW1sOkF0dHJpYnV0ZT48c2FtbDpBdHRyaWJ1dGUgTmFtZT0iU3VybmFtZSI+PHNhbWw6QXR0cmlidXRlVmFsdWU+SnVyaWs8L3NhbWw6QXR0cmlidXRlVmFsdWU+PC9zYW1sOkF0dHJpYnV0ZT48c2FtbDpBdHRyaWJ1dGUgTmFtZT0iRW1haWwiPjxzYW1sOkF0dHJpYnV0ZVZhbHVlPm1hdHQuanVyaWtAaHVsdS5jb208L3NhbWw6QXR0cmlidXRlVmFsdWU+PC9zYW1sOkF0dHJpYnV0ZT48L3NhbWw6QXR0cmlidXRlU3RhdGVtZW50Pjwvc2FtbDpBc3NlcnRpb24+PC9zYW1scDpSZXNwb25zZT4='
        response_x = OneLogin::RubySaml::Response.new(xml)
        response_x.settings = settings
        assert response_x.send(:validate_signature)
        assert_empty response_x.errors
      end

      it "return false when no fingerprint" do
        settings.idp_cert_fingerprint = nil
        settings.idp_cert = nil
        response.settings = settings
        assert !response.send(:validate_signature)
        assert_includes response.errors, "Invalid Signature on SAML Response"
      end

      it "return false when the signature is invalid" do
        settings.idp_cert_fingerprint = signature_fingerprint_1
        response.settings = settings
        assert !response.send(:validate_signature)
        assert_includes response.errors, "Invalid Signature on SAML Response"
      end

      it "return false when no X509Certificate and not cert provided at settings" do
        settings.idp_cert_fingerprint = ruby_saml_cert_fingerprint
        settings.idp_cert = nil
        response_valid_signed_without_x509certificate.settings = settings
        assert !response_valid_signed_without_x509certificate.send(:validate_signature)
        assert_includes response_valid_signed_without_x509certificate.errors, "Invalid Signature on SAML Response"
      end

      it "return false when no X509Certificate and the cert provided at settings mismatches" do
        settings.idp_cert_fingerprint = nil
        settings.idp_cert = signature_1
        response_valid_signed_without_x509certificate.settings = settings
        assert !response_valid_signed_without_x509certificate.send(:validate_signature)
        assert_includes response_valid_signed_without_x509certificate.errors, "Invalid Signature on SAML Response"
      end

      it "return true when no X509Certificate and the cert provided at settings matches" do
        settings.idp_cert_fingerprint = nil
        settings.idp_cert = ruby_saml_cert_text
        response_valid_signed_without_x509certificate.settings = settings
        assert response_valid_signed_without_x509certificate.send(:validate_signature)
        assert_empty response_valid_signed_without_x509certificate.errors
      end

      it "return false when signature wrapping attack" do
        signature_wrapping_attack = read_invalid_response("signature_wrapping_attack.xml.base64")
        response_wrapped = OneLogin::RubySaml::Response.new(signature_wrapping_attack)
        response_wrapped.stubs(:conditions).returns(nil)
        response_wrapped.stubs(:validate_subject_confirmation).returns(true)
        settings.idp_cert_fingerprint = "afe71c28ef740bc87425be13a2263d37971da1f9"
        response_wrapped.settings = settings
        assert !response_wrapped.send(:validate_signature)
        assert_includes response_wrapped.errors, "Invalid Signature on SAML Response"
      end
    end

    describe "#validate_signature with multiple idp certs" do
      it "return true when at least a cert on idp_cert_multi is valid" do
        settings.idp_cert_multi = {
          :signing => [ruby_saml_cert_text2, ruby_saml_cert_text],
          :encryption => []
        }
        response_valid_signed.settings = settings
        assert response_valid_signed.send(:validate_signature)
        assert_empty response_valid_signed.errors
      end

      it "return false when none cert on idp_cert_multi is valid" do
        settings.idp_cert_fingerprint = ruby_saml_cert_fingerprint
        settings.idp_cert_multi = {
          :signing => [ruby_saml_cert_text2, ruby_saml_cert_text2],
          :encryption => []
        }
        response_valid_signed.settings = settings
        assert !response_valid_signed.send(:validate_signature)
        assert_includes response_valid_signed.errors, "Invalid Signature on SAML Response"
      end
    end

    describe "#validate nameid" do
      it "return false when no nameid element and required by settings" do
        settings.security[:want_name_id] = true
        response_no_nameid.settings = settings
        assert !response_no_nameid.send(:validate_name_id)
        assert_includes response_no_nameid.errors, "No NameID element found in the assertion of the Response"
      end

      it "return false when no nameid element and required by settings" do
        response_empty_nameid.settings = settings
        assert !response_empty_nameid.send(:validate_name_id)
        assert_includes response_empty_nameid.errors, "An empty NameID value found"
      end

      it "return false when no nameid value" do
        response_empty_nameid.settings = settings
        assert !response_empty_nameid.send(:validate_name_id)
        assert_includes response_empty_nameid.errors, "An empty NameID value found"
      end

      it "return false when wrong_spnamequalifier" do
        settings.issuer = 'sp_entity_id'
        response_wrong_spnamequalifier.settings = settings
        assert !response_wrong_spnamequalifier.send(:validate_name_id)
        assert_includes response_wrong_spnamequalifier.errors, "The SPNameQualifier value mistmatch the SP entityID value."
      end

      it "return true when no nameid element but not required by settings" do
        settings.security[:want_name_id] = false
        response_no_nameid.settings = settings
        assert response_no_nameid.send(:validate_name_id)
      end

      it "return true when nameid is valid and response_wrong_spnamequalifier matches the SP issuer" do
        settings.issuer = 'wrong-sp-entityid'
        response_wrong_spnamequalifier.settings = settings
        assert response_wrong_spnamequalifier.send(:validate_name_id)
      end
    end

    describe "#nameid" do
      it "extract the value of the name id element" do
        assert_equal "support@onelogin.com", response.nameid
        assert_equal "someone@example.com", response_with_signed_assertion.nameid
      end

      it "be extractable from an OpenSAML response" do
        response_open_saml = OneLogin::RubySaml::Response.new(fixture(:open_saml))
        assert_equal "someone@example.org", response_open_saml.nameid
      end

      it "be extractable from a Simple SAML PHP response" do
        response_ssp = OneLogin::RubySaml::Response.new(fixture(:simple_saml_php))
        assert_equal "someone@example.com", response_ssp.nameid
      end
    end

    describe "#name_id_format" do
      it "extract the value of the name id element" do
        assert_equal "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress", response.name_id_format
        assert_equal "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress", response_with_signed_assertion.name_id_format
      end
    end

    describe "#sessionindex" do
      it "extract the value of the sessionindex element" do
        response = OneLogin::RubySaml::Response.new(fixture(:simple_saml_php))
        assert_equal "_51be37965feb5579d803141076936dc2e9d1d98ebf", response.sessionindex
      end
    end

    describe "#check_one_conditions" do
      it "return false when none or more than one conditions element" do
        response_no_conditions.soft = true
        assert !response_no_conditions.send(:validate_one_conditions)
        assert_includes response_no_conditions.errors, "The Assertion must include one Conditions element"
      end

      it "return true when one conditions element" do
        response.soft = true
        assert response.send(:validate_one_conditions)
      end
    end

    describe "#check_one_authnstatement" do
      it "return false when none or more than one authnstatement element" do
        response_no_authnstatement.soft = true
        assert !response_no_authnstatement.send(:validate_one_authnstatement)
        assert_includes response_no_authnstatement.errors, "The Assertion must include one AuthnStatement element"
      end

      it "return true when one authnstatement element" do
        response.soft = true
        assert response.send(:validate_one_authnstatement)
      end
    end

    describe "#check_conditions" do
      it "check time conditions" do
        response.soft = true
        assert !response.send(:validate_conditions)
        response_time_updated = OneLogin::RubySaml::Response.new(response_document_without_recipient_with_time_updated)
        response_time_updated.soft = true
        assert response_time_updated.send(:validate_conditions)
        Timecop.freeze(Time.parse("2011-06-14T18:25:01.516Z")) do
          response_with_saml2_namespace = OneLogin::RubySaml::Response.new(response_document_with_saml2_namespace)
          response_with_saml2_namespace.soft = true
          assert response_with_saml2_namespace.send(:validate_conditions)
        end
      end

      it "optionally allows for clock drift" do
        # The NotBefore condition in the document is 2011-06-14T18:21:01.516Z
        Timecop.freeze(Time.parse("2011-06-14T18:21:01Z")) do
          settings.soft = true
          special_response_with_saml2_namespace = OneLogin::RubySaml::Response.new(
            response_document_with_saml2_namespace,
            :allowed_clock_drift => 0.515,
            :settings => settings
          )
          assert !special_response_with_saml2_namespace.send(:validate_conditions)
        end

        Timecop.freeze(Time.parse("2011-06-14T18:21:01Z")) do
          special_response_with_saml2_namespace = OneLogin::RubySaml::Response.new(
            response_document_with_saml2_namespace,
            :allowed_clock_drift => 0.516
          )
          assert special_response_with_saml2_namespace.send(:validate_conditions)
        end
      end
    end

    describe "#attributes" do
      it "extract the first attribute in a hash accessed via its symbol" do
        assert_equal "demo", response.attributes[:uid]
      end

      it "extract the first attribute in a hash accessed via its name" do
        assert_equal "demo", response.attributes["uid"]
      end

      it "extract all attributes" do
        assert_equal "demo", response.attributes[:uid]
        assert_equal "value", response.attributes[:another_value]
      end

      it "work for implicit namespaces" do
        assert_equal "someone@example.com", response_with_signed_assertion.attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"]
      end

      it "extract attributes from all AttributeStatement tags" do
        assert_equal "smith", response_with_multiple_attribute_statements.attributes[:surname]
        assert_equal "bob", response_with_multiple_attribute_statements.attributes[:firstname]
      end

      it "not raise on responses without attributes" do
        assert_equal OneLogin::RubySaml::Attributes.new, response_unsigned.attributes
      end

      describe "#encrypted attributes" do
        it "raise error when the assertion contains encrypted attributes but no private key to decrypt" do
          settings.private_key = nil
          response_encrypted_attrs.settings = settings
          assert_raises(OneLogin::RubySaml::ValidationError, "An EncryptedAttribute found and no SP private key found on the settings to decrypt it") do
            attrs = response_encrypted_attrs.attributes
          end
        end

        it "extract attributes when the assertion contains encrypted attributes and the private key is provided" do
          settings.certificate = ruby_saml_cert_text
          settings.private_key = ruby_saml_key_text
          response_encrypted_attrs.settings = settings
          attributes = response_encrypted_attrs.attributes
          assert_equal "test", attributes[:uid]
          assert_equal "test@example.com", attributes[:mail]
        end
      end

      it "return false when validating a response with duplicate attributes" do
        response_duplicated_attributes.settings = settings
        response_duplicated_attributes.options[:check_duplicated_attributes] = true
        assert !response_duplicated_attributes.send(:validate_no_duplicated_attributes)
        assert_includes response_duplicated_attributes.errors, "Found an Attribute element with duplicated Name"
      end

      it "return true when validating a response with duplicate attributes but skip check" do
        response_duplicated_attributes.settings = settings
        assert response_duplicated_attributes.send(:validate_no_duplicated_attributes)
      end

      describe "#multiple values" do
        it "extract single value as string" do
          assert_equal "demo", response_multiple_attr_values.attributes[:uid]
        end

        it "extract single value as string in compatibility mode off" do
          OneLogin::RubySaml::Attributes.single_value_compatibility = false
          assert_equal ["demo"], response_multiple_attr_values.attributes[:uid]
          # classes are not reloaded between tests so restore default
          OneLogin::RubySaml::Attributes.single_value_compatibility = true
        end

        it "extract first of multiple values as string for b/w compatibility" do
          assert_equal 'value1', response_multiple_attr_values.attributes[:another_value]
        end

        it "extract first of multiple values as string for b/w compatibility in compatibility mode off" do
          OneLogin::RubySaml::Attributes.single_value_compatibility = false
          assert_equal ['value1', 'value2'], response_multiple_attr_values.attributes[:another_value]
          OneLogin::RubySaml::Attributes.single_value_compatibility = true
        end

        it "return array with all attributes when asked in XML order" do
          assert_equal ['value1', 'value2'], response_multiple_attr_values.attributes.multi(:another_value)
        end

        it "return array with all attributes when asked in XML order in compatibility mode off" do
          OneLogin::RubySaml::Attributes.single_value_compatibility = false
          assert_equal ['value1', 'value2'], response_multiple_attr_values.attributes.multi(:another_value)
          OneLogin::RubySaml::Attributes.single_value_compatibility = true
        end

        it "return first of multiple values when multiple Attribute tags in XML" do
          assert_equal 'role1', response_multiple_attr_values.attributes[:role]
        end

        it "return first of multiple values when multiple Attribute tags in XML in compatibility mode off" do
          OneLogin::RubySaml::Attributes.single_value_compatibility = false
          assert_equal ['role1', 'role2', 'role3'], response_multiple_attr_values.attributes[:role]
          OneLogin::RubySaml::Attributes.single_value_compatibility = true
        end

        it "return all of multiple values in reverse order when multiple Attribute tags in XML" do
          assert_equal ['role1', 'role2', 'role3'], response_multiple_attr_values.attributes.multi(:role)
        end

        it "return all of multiple values in reverse order when multiple Attribute tags in XML in compatibility mode off" do
          OneLogin::RubySaml::Attributes.single_value_compatibility = false
          assert_equal ['role1', 'role2', 'role3'], response_multiple_attr_values.attributes.multi(:role)
          OneLogin::RubySaml::Attributes.single_value_compatibility = true
        end

        it "return all of multiple values when multiple Attribute tags in multiple AttributeStatement tags" do
          OneLogin::RubySaml::Attributes.single_value_compatibility = false
          assert_equal ['role1', 'role2', 'role3'], response_with_multiple_attribute_statements.attributes.multi(:role)
          OneLogin::RubySaml::Attributes.single_value_compatibility = true
        end

        it "return nil value correctly" do
          assert_nil response_multiple_attr_values.attributes[:attribute_with_nil_value]
        end

        it "return nil value correctly when not in compatibility mode off" do
          OneLogin::RubySaml::Attributes.single_value_compatibility = false
          assert_equal [nil], response_multiple_attr_values.attributes[:attribute_with_nil_value]
          OneLogin::RubySaml::Attributes.single_value_compatibility = true
        end

        it "return multiple values including nil and empty string" do
          response = OneLogin::RubySaml::Response.new(fixture(:response_with_multiple_attribute_values))
          assert_equal ["", "valuePresent", nil, nil], response.attributes.multi(:attribute_with_nils_and_empty_strings)
        end

        it "return multiple values from [] when not in compatibility mode off" do
          OneLogin::RubySaml::Attributes.single_value_compatibility = false
          assert_equal ["", "valuePresent", nil, nil], response_multiple_attr_values.attributes[:attribute_with_nils_and_empty_strings]
          OneLogin::RubySaml::Attributes.single_value_compatibility = true
        end

        it "check what happens when trying retrieve attribute that does not exists" do
          assert_nil response_multiple_attr_values.attributes[:attribute_not_exists]
          assert_nil response_multiple_attr_values.attributes.single(:attribute_not_exists)
          assert_nil response_multiple_attr_values.attributes.multi(:attribute_not_exists)

          OneLogin::RubySaml::Attributes.single_value_compatibility = false
          assert_nil response_multiple_attr_values.attributes[:attribute_not_exists]
          assert_nil response_multiple_attr_values.attributes.single(:attribute_not_exists)
          assert_nil response_multiple_attr_values.attributes.multi(:attribute_not_exists)
          OneLogin::RubySaml::Attributes.single_value_compatibility = true
        end

      end
    end

    describe "#session_expires_at" do
      it "extract the value of the SessionNotOnOrAfter attribute" do
        assert response.session_expires_at.is_a?(Time)
      end

      it "return nil when the value of the SessionNotOnOrAfter is not set" do
        assert_nil response_without_attributes.session_expires_at
      end
    end

    describe "#success" do
      it "find a status code that says success" do
        response.success?
      end
    end

    describe '#xpath_first_from_signed_assertion' do
      it 'not allow arbitrary code execution' do
        malicious_response_document = fixture('response_eval', false)
        malicious_response = OneLogin::RubySaml::Response.new(malicious_response_document)
        malicious_response.send(:xpath_first_from_signed_assertion)
        assert_nil $evalled
      end
    end

    describe '#sign_document' do
      it 'Sign an unsigned SAML Response XML and initiate the SAML object with it' do
        xml = Base64.decode64(fixture("test_sign.xml"))

        document = XMLSecurity::Document.new(xml)

        formatted_cert = OneLogin::RubySaml::Utils.format_cert(ruby_saml_cert_text)
        cert = OpenSSL::X509::Certificate.new(formatted_cert)

        formatted_private_key = OneLogin::RubySaml::Utils.format_private_key(ruby_saml_key_text)
        private_key = OpenSSL::PKey::RSA.new(formatted_private_key)
        document.sign_document(private_key, cert)

        signed_response = OneLogin::RubySaml::Response.new(document.to_s)
        settings.assertion_consumer_service_url = "http://recipient"
        settings.idp_cert = ruby_saml_cert_text
        signed_response.settings = settings
        Timecop.freeze(Time.parse("2015-03-18T04:50:24Z")) do
          assert signed_response.is_valid?
        end
        assert_empty signed_response.errors
      end
    end

    describe '#want_assertion_signed' do
      before do
        settings.security[:want_assertions_signed] = true
        @signed_assertion = OneLogin::RubySaml::Response.new(response_document_with_signed_assertion, :settings => settings)
        @no_signed_assertion = OneLogin::RubySaml::Response.new(response_document_valid_signed, :settings => settings)
      end


      it 'returns false if :want_assertion_signed enabled and Assertion not signed' do
        assert !@no_signed_assertion.send(:validate_signed_elements)
        assert_includes @no_signed_assertion.errors, "The Assertion of the Response is not signed and the SP requires it"

      end

      it 'returns true if :want_assertion_signed enabled and Assertion is signed' do
        assert @signed_assertion.send(:validate_signed_elements)
        assert_empty @signed_assertion.errors
      end
    end

    describe "retrieve nameID" do
      it 'is possible  when nameID inside the assertion' do
        response_valid_signed.settings = settings
        assert_equal "test@onelogin.com", response_valid_signed.nameid
      end

      it 'is not possible when encryptID inside the assertion but no private key' do
        response_encrypted_nameid.settings = settings
        assert_raises(OneLogin::RubySaml::ValidationError, "An EncryptedID found and no SP private key found on the settings to decrypt it") do
          assert_equal "test@onelogin.com", response_encrypted_nameid.nameid
        end

        assert_raises(OneLogin::RubySaml::ValidationError, "An EncryptedID found and no SP private key found on the settings to decrypt it") do
          assert_equal "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress", response_encrypted_nameid.name_id_format
        end
      end

      it 'is possible when encryptID inside the assertion and settings has the private key' do
        settings.private_key = ruby_saml_key_text
        response_encrypted_nameid.settings = settings
        assert_equal "test@onelogin.com", response_encrypted_nameid.nameid
        assert_equal "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress", response_encrypted_nameid.name_id_format
      end

    end

    describe 'try to initialize an encrypted response' do
      it 'raise if an encrypted assertion is found and no sp private key to decrypt it' do
        error_msg = "An EncryptedAssertion found and no SP private key found on the settings to decrypt it. Be sure you provided the :settings parameter at the initialize method"

        assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
          response = OneLogin::RubySaml::Response.new(signed_message_encrypted_unsigned_assertion)
        end

        assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
          response2 = OneLogin::RubySaml::Response.new(signed_message_encrypted_unsigned_assertion, :settings => settings)
        end

        settings.certificate = ruby_saml_cert_text
        settings.private_key = ruby_saml_key_text
        assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
          response3 = OneLogin::RubySaml::Response.new(signed_message_encrypted_unsigned_assertion)
          response3.settings
        end
      end

      it 'raise if an encrypted assertion is found and the sp private key is wrong' do
        settings.certificate = ruby_saml_cert_text
        wrong_private_key = ruby_saml_key_text.sub!('A', 'B')
        settings.private_key = wrong_private_key

        error_msg = "Neither PUB key nor PRIV key: nested asn1 error"
        assert_raises(OpenSSL::PKey::RSAError, error_msg) do
          response = OneLogin::RubySaml::Response.new(signed_message_encrypted_unsigned_assertion, :settings => settings)
        end
      end

      it 'return true if an encrypted assertion is found and settings initialized with private_key' do
        settings.certificate = ruby_saml_cert_text
        settings.private_key = ruby_saml_key_text
        response = OneLogin::RubySaml::Response.new(signed_message_encrypted_unsigned_assertion, :settings => settings)
        assert response.decrypted_document

        response2 = OneLogin::RubySaml::Response.new(signed_message_encrypted_signed_assertion, :settings => settings)
        assert response2.decrypted_document

        response3 = OneLogin::RubySaml::Response.new(unsigned_message_encrypted_signed_assertion, :settings => settings)
        assert response3.decrypted_document

        response4 = OneLogin::RubySaml::Response.new(unsigned_message_encrypted_unsigned_assertion, :settings => settings)
        assert response4.decrypted_document

        assert OneLogin::RubySaml::Response.new(
          Base64.encode64(File.read('test/responses/unsigned_encrypted_adfs.xml')),
          :settings => settings
        ).decrypted_document
      end
    end

    describe "retrieve nameID and attributes from encrypted assertion" do

      before do
        settings.idp_cert_fingerprint = 'EE:17:4E:FB:A8:81:71:12:0D:2A:78:43:BC:E7:0C:07:58:79:F4:F4'
        settings.issuer = 'http://rubysaml.com:3000/saml/metadata'
        settings.assertion_consumer_service_url = 'http://rubysaml.com:3000/saml/acs'
        settings.certificate = ruby_saml_cert_text
        settings.private_key = ruby_saml_key_text
      end

      it 'is possible when signed_message_encrypted_unsigned_assertion' do
        response = OneLogin::RubySaml::Response.new(signed_message_encrypted_unsigned_assertion, :settings => settings)
        Timecop.freeze(Time.parse("2015-03-19T14:30:31Z")) do
          assert response.is_valid?
          assert_empty response.errors
          assert_equal "test", response.attributes[:uid]
          assert_equal "98e2bb61075e951b37d6b3be6954a54b340d86c7", response.nameid
        end
      end

      it 'is possible when signed_message_encrypted_signed_assertion' do
        response = OneLogin::RubySaml::Response.new(signed_message_encrypted_signed_assertion, :settings => settings)
        Timecop.freeze(Time.parse("2015-03-19T14:30:31Z")) do
          assert response.is_valid?
          assert_empty response.errors
          assert_equal "test", response.attributes[:uid]
          assert_equal "98e2bb61075e951b37d6b3be6954a54b340d86c7", response.nameid
        end
      end

      it 'is possible when unsigned_message_encrypted_signed_assertion' do
        response = OneLogin::RubySaml::Response.new(unsigned_message_encrypted_signed_assertion, :settings => settings)
        Timecop.freeze(Time.parse("2015-03-19T14:30:31Z")) do
          assert response.is_valid?
          assert_empty response.errors
          assert_equal "test", response.attributes[:uid]
          assert_equal "98e2bb61075e951b37d6b3be6954a54b340d86c7", response.nameid
        end
      end

      it 'is not possible when unsigned_message_encrypted_unsigned_assertion' do
        response = OneLogin::RubySaml::Response.new(unsigned_message_encrypted_unsigned_assertion, :settings => settings)
        Timecop.freeze(Time.parse("2015-03-19T14:30:31Z")) do
          assert !response.is_valid?
          assert_includes response.errors, "Found an unexpected number of Signature Element. SAML Response rejected"
        end
      end
    end

    describe "#decrypt_assertion" do
      before do
        settings.private_key = ruby_saml_key_text
      end

      describe "check right settings" do

        it "is not possible to decrypt the assertion if no private key" do
          response = OneLogin::RubySaml::Response.new(signed_message_encrypted_unsigned_assertion, :settings => settings)

          encrypted_assertion_node = REXML::XPath.first(
            response.document,
            "(/p:Response/EncryptedAssertion/)|(/p:Response/a:EncryptedAssertion/)",
            { "p" => "urn:oasis:names:tc:SAML:2.0:protocol", "a" => "urn:oasis:names:tc:SAML:2.0:assertion" }
          )
          response.settings.private_key = nil

          error_msg = "An EncryptedAssertion found and no SP private key found on the settings to decrypt it"
          assert_raises(OneLogin::RubySaml::ValidationError, error_msg) do
            decrypted = response.send(:decrypt_assertion, encrypted_assertion_node)
          end
        end

        it "is possible to decrypt the assertion if private key" do
          response = OneLogin::RubySaml::Response.new(signed_message_encrypted_unsigned_assertion, :settings => settings)

          encrypted_assertion_node = REXML::XPath.first(
            response.document,
            "(/p:Response/EncryptedAssertion/)|(/p:Response/a:EncryptedAssertion/)",
            { "p" => "urn:oasis:names:tc:SAML:2.0:protocol", "a" => "urn:oasis:names:tc:SAML:2.0:assertion" }
          )
          decrypted = response.send(:decrypt_assertion, encrypted_assertion_node)

          encrypted_assertion_node2 = REXML::XPath.first(
            decrypted,
            "(/p:Response/EncryptedAssertion/)|(/p:Response/a:EncryptedAssertion/)",
            { "p" => "urn:oasis:names:tc:SAML:2.0:protocol", "a" => "urn:oasis:names:tc:SAML:2.0:assertion" }
          )
          assert_nil encrypted_assertion_node2
          assert decrypted.name, "Assertion"
        end

        it "is possible to decrypt the assertion if private key provided and EncryptedKey RetrievalMethod presents in response" do
          settings.private_key = ruby_saml_key_text
          resp = read_response('response_with_retrieval_method.xml')
          response = OneLogin::RubySaml::Response.new(resp, :settings => settings)

          encrypted_assertion_node = REXML::XPath.first(
            response.document,
            "(/p:Response/EncryptedAssertion/)|(/p:Response/a:EncryptedAssertion/)",
            { "p" => "urn:oasis:names:tc:SAML:2.0:protocol", "a" => "urn:oasis:names:tc:SAML:2.0:assertion" }
          )
          decrypted = response.send(:decrypt_assertion, encrypted_assertion_node)

          encrypted_assertion_node2 = REXML::XPath.first(
            decrypted,
            "(/p:Response/EncryptedAssertion/)|(/p:Response/a:EncryptedAssertion/)",
            { "p" => "urn:oasis:names:tc:SAML:2.0:protocol", "a" => "urn:oasis:names:tc:SAML:2.0:assertion" }
          )

          assert_nil encrypted_assertion_node2
          assert decrypted.name, "Assertion"
        end

        it "is possible to decrypt the assertion if private key but no saml namespace on the Assertion Element that is inside the EncryptedAssertion" do
          unsigned_message_encrypted_assertion_without_saml_namespace = read_response('unsigned_message_encrypted_assertion_without_saml_namespace.xml.base64')
          response = OneLogin::RubySaml::Response.new(unsigned_message_encrypted_assertion_without_saml_namespace, :settings => settings)
          encrypted_assertion_node = REXML::XPath.first(
            response.document,
            "(/p:Response/EncryptedAssertion/)|(/p:Response/a:EncryptedAssertion/)",
            { "p" => "urn:oasis:names:tc:SAML:2.0:protocol", "a" => "urn:oasis:names:tc:SAML:2.0:assertion" }
          )
          decrypted = response.send(:decrypt_assertion, encrypted_assertion_node)

          encrypted_assertion_node2 = REXML::XPath.first(
            decrypted,
            "(/p:Response/EncryptedAssertion/)|(/p:Response/a:EncryptedAssertion/)",
            { "p" => "urn:oasis:names:tc:SAML:2.0:protocol", "a" => "urn:oasis:names:tc:SAML:2.0:assertion" }
          )
          assert_nil encrypted_assertion_node2
          assert decrypted.name, "Assertion"
        end
      end

      describe "check different encrypt methods supported" do
        it "EncryptionMethod DES-192 && Key Encryption Algorithm RSA-1_5" do
          unsigned_message_des192_encrypted_signed_assertion = read_response('unsigned_message_des192_encrypted_signed_assertion.xml.base64')
          response = OneLogin::RubySaml::Response.new(unsigned_message_des192_encrypted_signed_assertion, :settings => settings)
          assert_equal "test", response.attributes[:uid]
          assert_equal "_ce3d2948b4cf20146dee0a0b3dd6f69b6cf86f62d7", response.nameid
        end

        it "EncryptionMethod AES-128 && Key Encryption Algorithm RSA-OAEP-MGF1P" do
          unsigned_message_aes128_encrypted_signed_assertion = read_response('unsigned_message_aes128_encrypted_signed_assertion.xml.base64')
          response = OneLogin::RubySaml::Response.new(unsigned_message_aes128_encrypted_signed_assertion, :settings => settings)
          assert_equal "test", response.attributes[:uid]
          assert_equal "_ce3d2948b4cf20146dee0a0b3dd6f69b6cf86f62d7", response.nameid
        end

        it "EncryptionMethod AES-192 && Key Encryption Algorithm RSA-OAEP-MGF1P" do
          unsigned_message_aes192_encrypted_signed_assertion = read_response('unsigned_message_aes192_encrypted_signed_assertion.xml.base64')
          response = OneLogin::RubySaml::Response.new(unsigned_message_aes192_encrypted_signed_assertion, :settings => settings)
          assert_equal "test", response.attributes[:uid]
          assert_equal "_ce3d2948b4cf20146dee0a0b3dd6f69b6cf86f62d7", response.nameid
        end

        it "EncryptionMethod AES-256 && Key Encryption Algorithm RSA-OAEP-MGF1P" do
          unsigned_message_aes256_encrypted_signed_assertion = read_response('unsigned_message_aes256_encrypted_signed_assertion.xml.base64')
          response = OneLogin::RubySaml::Response.new(unsigned_message_aes256_encrypted_signed_assertion, :settings => settings)
          assert_equal "test", response.attributes[:uid]
          assert_equal "_ce3d2948b4cf20146dee0a0b3dd6f69b6cf86f62d7", response.nameid
        end
      end

    end
    describe "test qualified name id in attributes" do

      it "parsed the nameid" do
        response = OneLogin::RubySaml::Response.new(read_response("signed_nameid_in_atts.xml"), :settings => settings)
        response.settings.idp_cert_fingerprint = 'c51985d947f1be57082025050846eb27f6cab783'
        assert_empty response.errors
        assert_equal "test", response.attributes[:uid]
        assert_equal "http://idp.example.com/metadata.php/ZdrjpwEdw22vKoxWAbZB78/gQ7s=", response.attributes.single('urn:oid:1.3.6.1.4.1.5923.1.1.1.10')
      end
    end

    describe "test unqualified name id in attributes" do

      it "parsed the nameid" do
        response = OneLogin::RubySaml::Response.new(read_response("signed_unqual_nameid_in_atts.xml"), :settings => settings)
        response.settings.idp_cert_fingerprint = 'c51985d947f1be57082025050846eb27f6cab783'
        assert_empty response.errors
        assert_equal "test", response.attributes[:uid]
        assert_equal "ZdrjpwEdw22vKoxWAbZB78/gQ7s=", response.attributes.single('urn:oid:1.3.6.1.4.1.5923.1.1.1.10')
      end
    end

    describe "signature wrapping attack with encrypted assertion" do
      it "should not be valid" do
        settings.private_key = ruby_saml_key_text
        signature_wrapping_attack = read_invalid_response("encrypted_new_attack.xml.base64")
        response_wrapped = OneLogin::RubySaml::Response.new(signature_wrapping_attack, :settings => settings)
        response_wrapped.stubs(:conditions).returns(nil)
        response_wrapped.stubs(:validate_subject_confirmation).returns(true)
        settings.idp_cert_fingerprint = "385b1eec71143f00db6af936e2ea12a28771d72c"
        assert !response_wrapped.is_valid?
        assert_includes response_wrapped.errors, "Found an invalid Signed Element. SAML Response rejected"
      end
    end

    describe "signature wrapping attack - concealed SAML response body" do
      it "should not be valid" do
        signature_wrapping_attack = read_invalid_response("response_with_concealed_signed_assertion.xml")
        response_wrapped = OneLogin::RubySaml::Response.new(signature_wrapping_attack, :settings => settings)
        settings.idp_cert_fingerprint = '4b68c453c7d994aad9025c99d5efcf566287fe8d'
        response_wrapped.stubs(:conditions).returns(nil)
        response_wrapped.stubs(:validate_subject_confirmation).returns(true)
        assert !response_wrapped.is_valid?
        assert_includes response_wrapped.errors, "SAML Response must contain 1 assertion"
      end
    end

    describe "signature wrapping attack - doubled signed assertion SAML response" do
      it "should not be valid" do
        signature_wrapping_attack = read_invalid_response("response_with_doubled_signed_assertion.xml")
        response_wrapped = OneLogin::RubySaml::Response.new(signature_wrapping_attack, :settings => settings)
        settings.idp_cert_fingerprint = '4b68c453c7d994aad9025c99d5efcf566287fe8d'
        response_wrapped.stubs(:conditions).returns(nil)
        response_wrapped.stubs(:validate_subject_confirmation).returns(true)
        assert !response_wrapped.is_valid?
        assert_includes response_wrapped.errors, "SAML Response must contain 1 assertion"
      end
    end
  end
end
