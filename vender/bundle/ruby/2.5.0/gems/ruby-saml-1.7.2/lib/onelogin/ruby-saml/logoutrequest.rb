require "onelogin/ruby-saml/logging"
require "onelogin/ruby-saml/saml_message"
require "onelogin/ruby-saml/utils"

# Only supports SAML 2.0
module OneLogin
  module RubySaml

    # SAML2 Logout Request (SLO SP initiated, Builder)
    #
    class Logoutrequest < SamlMessage

      # Logout Request ID
      attr_reader :uuid

      # Initializes the Logout Request. A Logoutrequest Object that is an extension of the SamlMessage class.
      # Asigns an ID, a random uuid.
      #
      def initialize
        @uuid = OneLogin::RubySaml::Utils.uuid
      end

      # Creates the Logout Request string.
      # @param settings [OneLogin::RubySaml::Settings|nil] Toolkit settings
      # @param params [Hash] Some extra parameters to be added in the GET for example the RelayState
      # @return [String] Logout Request string that includes the SAMLRequest
      #
      def create(settings, params={})
        params = create_params(settings, params)
        params_prefix = (settings.idp_slo_target_url =~ /\?/) ? '&' : '?'
        saml_request = CGI.escape(params.delete("SAMLRequest"))
        request_params = "#{params_prefix}SAMLRequest=#{saml_request}"
        params.each_pair do |key, value|
          request_params << "&#{key.to_s}=#{CGI.escape(value.to_s)}"
        end
        @logout_url = settings.idp_slo_target_url + request_params
      end

      # Creates the Get parameters for the logout request.
      # @param settings [OneLogin::RubySaml::Settings|nil] Toolkit settings
      # @param params [Hash] Some extra parameters to be added in the GET for example the RelayState
      # @return [Hash] Parameters
      #
      def create_params(settings, params={})
        # The method expects :RelayState but sometimes we get 'RelayState' instead.
        # Based on the HashWithIndifferentAccess value in Rails we could experience
        # conflicts so this line will solve them.
        relay_state = params[:RelayState] || params['RelayState']

        request_doc = create_logout_request_xml_doc(settings)
        request_doc.context[:attribute_quote] = :quote if settings.double_quote_xml_attribute_values

        request = ""
        request_doc.write(request)

        Logging.debug "Created SLO Logout Request: #{request}"

        request = deflate(request) if settings.compress_request
        base64_request = encode(request)
        request_params = {"SAMLRequest" => base64_request}

        if settings.security[:logout_requests_signed] && !settings.security[:embed_sign] && settings.private_key
          params['SigAlg']    = settings.security[:signature_method]
          url_string = OneLogin::RubySaml::Utils.build_query(
            :type => 'SAMLRequest',
            :data => base64_request,
            :relay_state => relay_state,
            :sig_alg => params['SigAlg']
          )
          sign_algorithm = XMLSecurity::BaseDocument.new.algorithm(settings.security[:signature_method])
          signature = settings.get_sp_key.sign(sign_algorithm.new, url_string)
          params['Signature'] = encode(signature)
        end

        params.each_pair do |key, value|
          request_params[key] = value.to_s
        end

        request_params
      end

      # Creates the SAMLRequest String.
      # @param settings [OneLogin::RubySaml::Settings|nil] Toolkit settings
      # @return [String] The SAMLRequest String.
      #
      def create_logout_request_xml_doc(settings)
        time = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")

        request_doc = XMLSecurity::Document.new
        request_doc.uuid = uuid

        root = request_doc.add_element "samlp:LogoutRequest", { "xmlns:samlp" => "urn:oasis:names:tc:SAML:2.0:protocol", "xmlns:saml" => "urn:oasis:names:tc:SAML:2.0:assertion" }
        root.attributes['ID'] = uuid
        root.attributes['IssueInstant'] = time
        root.attributes['Version'] = "2.0"
        root.attributes['Destination'] = settings.idp_slo_target_url  unless settings.idp_slo_target_url.nil?

        if settings.issuer
          issuer = root.add_element "saml:Issuer"
          issuer.text = settings.issuer
        end

        nameid = root.add_element "saml:NameID"
        if settings.name_identifier_value
          nameid.attributes['NameQualifier'] = settings.idp_name_qualifier if settings.idp_name_qualifier
          nameid.attributes['SPNameQualifier'] = settings.sp_name_qualifier if settings.sp_name_qualifier
          nameid.attributes['Format'] = settings.name_identifier_format if settings.name_identifier_format
          nameid.text = settings.name_identifier_value
        else
          # If no NameID is present in the settings we generate one
          nameid.text = OneLogin::RubySaml::Utils.uuid
          nameid.attributes['Format'] = 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
        end

        if settings.sessionindex
          sessionindex = root.add_element "samlp:SessionIndex"
          sessionindex.text = settings.sessionindex
        end

        # embed signature
        if settings.security[:logout_requests_signed] && settings.private_key && settings.certificate && settings.security[:embed_sign]
          private_key = settings.get_sp_key
          cert = settings.get_sp_cert
          request_doc.sign_document(private_key, cert, settings.security[:signature_method], settings.security[:digest_method])
        end

        request_doc
      end
    end
  end
end
