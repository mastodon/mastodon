require 'zlib'
require 'time'
require 'nokogiri'

require "onelogin/ruby-saml/saml_message"

# Only supports SAML 2.0
module OneLogin
  module RubySaml

    # SAML2 Logout Request (SLO IdP initiated, Parser)
    #
    class SloLogoutrequest < SamlMessage
      include ErrorHandling

      # OneLogin::RubySaml::Settings Toolkit settings
      attr_accessor :settings

      attr_reader :document
      attr_reader :request
      attr_reader :options

      attr_accessor :soft

      # Constructs the Logout Request. A Logout Request Object that is an extension of the SamlMessage class.
      # @param request [String] A UUEncoded Logout Request from the IdP.
      # @param options [Hash]  :settings to provide the OneLogin::RubySaml::Settings object 
      #                        Or :allowed_clock_drift for the logout request validation process to allow a clock drift when checking dates with
      #                        Or :relax_signature_validation to accept signatures if no idp certificate registered on settings 
      #
      # @raise [ArgumentError] If Request is nil
      #
      def initialize(request, options = {})
        raise ArgumentError.new("Request cannot be nil") if request.nil?

        @errors = []
        @options = options
        @soft = true
        unless options[:settings].nil?
          @settings = options[:settings]
          unless @settings.soft.nil?
            @soft = @settings.soft
          end
        end

        @request = decode_raw_saml(request)
        @document = REXML::Document.new(@request)
      end

      # Validates the Logout Request with the default values (soft = true)
      # @param collect_errors [Boolean] Stop validation when first error appears or keep validating.
      # @return [Boolean] TRUE if the Logout Request is valid
      #
      def is_valid?(collect_errors = false)
        validate(collect_errors)
      end

      # @return [String] Gets the NameID of the Logout Request.
      #
      def name_id
        @name_id ||= begin
          node = REXML::XPath.first(document, "/p:LogoutRequest/a:NameID", { "p" => PROTOCOL, "a" => ASSERTION })
          Utils.element_text(node)
        end
      end

      alias_method :nameid, :name_id

      # @return [String] Gets the NameID Format of the Logout Request.
      #
      def name_id_format
        @name_id_node ||= REXML::XPath.first(document, "/p:LogoutRequest/a:NameID", { "p" => PROTOCOL, "a" => ASSERTION })
        @name_id_format ||=
          if @name_id_node && @name_id_node.attribute("Format")
            @name_id_node.attribute("Format").value
          end
      end

      alias_method :nameid_format, :name_id_format

      # @return [String|nil] Gets the ID attribute from the Logout Request. if exists.
      #
      def id
        super(document)
      end

      # @return [String] Gets the Issuer from the Logout Request.
      #
      def issuer
        @issuer ||= begin
          node = REXML::XPath.first(
            document,
            "/p:LogoutRequest/a:Issuer",
            { "p" => PROTOCOL, "a" => ASSERTION }
          )
          Utils.element_text(node)
        end
      end

      # @return [Time|nil] Gets the NotOnOrAfter Attribute value if exists.
      #
      def not_on_or_after
        @not_on_or_after ||= begin
          node = REXML::XPath.first(
            document,
            "/p:LogoutRequest",
            { "p" => PROTOCOL }
          )
          if node && node.attributes["NotOnOrAfter"]
            Time.parse(node.attributes["NotOnOrAfter"])
          end
        end
      end

      # @return [Array] Gets the SessionIndex if exists (Supported multiple values). Empty Array if none found
      #
      def session_indexes
        nodes = REXML::XPath.match(
          document,
          "/p:LogoutRequest/p:SessionIndex",
          { "p" => PROTOCOL }
        )

        nodes.map { |node| Utils.element_text(node) }
      end

      private

      # Hard aux function to validate the Logout Request
      # @param collect_errors [Boolean] Stop validation when first error appears or keep validating. (if soft=true)
      # @return [Boolean] TRUE if the Logout Request is valid
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate(collect_errors = false)
        reset_errors!

        validations = [
          :validate_request_state,
          :validate_id,
          :validate_version,
          :validate_structure,
          :validate_not_on_or_after,
          :validate_issuer,
          :validate_signature
        ]

        if collect_errors
          validations.each { |validation| send(validation) }
          @errors.empty?
        else
          validations.all? { |validation| send(validation) }
        end
      end

      # Validates that the Logout Request contains an ID
      # If fails, the error is added to the errors array.
      # @return [Boolean] True if the Logout Request contains an ID, otherwise returns False
      #
      def validate_id
        unless id
          return append_error("Missing ID attribute on Logout Request")
        end

        true
      end

      # Validates the SAML version (2.0)
      # If fails, the error is added to the errors array.
      # @return [Boolean] True if the Logout Request is 2.0, otherwise returns False
      #
      def validate_version
        unless version(document) == "2.0"
          return append_error("Unsupported SAML version")
        end

        true
      end

      # Validates the time. (If the logout request was initialized with the :allowed_clock_drift option, the timing validations are relaxed by the allowed_clock_drift value)
      # If fails, the error is added to the errors array
      # @return [Boolean] True if satisfies the conditions, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_not_on_or_after
        now = Time.now.utc
        if not_on_or_after && now >= (not_on_or_after + (options[:allowed_clock_drift] || 0))
          return append_error("Current time is on or after NotOnOrAfter (#{now} >= #{not_on_or_after})")
        end

        true
      end

      # Validates the Logout Request against the specified schema.
      # @return [Boolean] True if the XML is valid, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails 
      #
      def validate_structure
        unless valid_saml?(document, soft)
          return append_error("Invalid SAML Logout Request. Not match the saml-schema-protocol-2.0.xsd")
        end

        true
      end

      # Validates that the Logout Request provided in the initialization is not empty, 
      # @return [Boolean] True if the required info is found, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_request_state
        return append_error("Blank logout request") if request.nil? || request.empty?

        true
      end

      # Validates the Issuer of the Logout Request
      # If fails, the error is added to the errors array
      # @return [Boolean] True if the Issuer matchs the IdP entityId, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_issuer
        return true if settings.nil? || settings.idp_entity_id.nil? || issuer.nil?

        unless OneLogin::RubySaml::Utils.uri_match?(issuer, settings.idp_entity_id)
          return append_error("Doesn't match the issuer, expected: <#{settings.idp_entity_id}>, but was: <#{issuer}>")
        end

        true
      end

      # Validates the Signature if exists and GET parameters are provided
      # @return [Boolean] True if not contains a Signature or if the Signature is valid, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_signature
        return true if options.nil?
        return true unless options.has_key? :get_params
        return true unless options[:get_params].has_key? 'Signature'

        # SAML specifies that the signature should be derived from a concatenation
        # of URI-encoded values _as sent by the IDP_:
        #
        # > Further, note that URL-encoding is not canonical; that is, there are multiple legal encodings for a given
        # > value. The relying party MUST therefore perform the verification step using the original URL-encoded
        # > values it received on the query string. It is not sufficient to re-encode the parameters after they have been
        # > processed by software because the resulting encoding may not match the signer's encoding.
        #
        # <http://docs.oasis-open.org/security/saml/v2.0/saml-bindings-2.0-os.pdf>
        #
        # If we don't have the original parts (for backward compatibility) required to correctly verify the signature,
        # then fabricate them by re-encoding the parsed URI parameters, and hope that we're lucky enough to use
        # the exact same URI-encoding as the IDP. (This is not the case if the IDP is ADFS!)
        options[:raw_get_params] ||= {}
        if options[:raw_get_params]['SAMLRequest'].nil? && !options[:get_params]['SAMLRequest'].nil?
          options[:raw_get_params]['SAMLRequest'] = CGI.escape(options[:get_params]['SAMLRequest'])
        end
        if options[:raw_get_params]['RelayState'].nil? && !options[:get_params]['RelayState'].nil?
          options[:raw_get_params]['RelayState'] = CGI.escape(options[:get_params]['RelayState'])
        end
        if options[:raw_get_params]['SigAlg'].nil? && !options[:get_params]['SigAlg'].nil?
          options[:raw_get_params]['SigAlg'] = CGI.escape(options[:get_params]['SigAlg'])
        end

        # If we only received the raw version of SigAlg,
        # then parse it back into the decoded params hash for convenience.
        if options[:get_params]['SigAlg'].nil? && !options[:raw_get_params]['SigAlg'].nil?
          options[:get_params]['SigAlg'] = CGI.unescape(options[:raw_get_params]['SigAlg'])
        end

        idp_cert = settings.get_idp_cert
        idp_certs = settings.get_idp_cert_multi

        if idp_cert.nil? && (idp_certs.nil? || idp_certs[:signing].empty?)
          return options.has_key? :relax_signature_validation
        end

        query_string = OneLogin::RubySaml::Utils.build_query_from_raw_parts(
          :type            => 'SAMLRequest',
          :raw_data        => options[:raw_get_params]['SAMLRequest'],
          :raw_relay_state => options[:raw_get_params]['RelayState'],
          :raw_sig_alg     => options[:raw_get_params]['SigAlg']
        )

        if idp_certs.nil? || idp_certs[:signing].empty?
          valid = OneLogin::RubySaml::Utils.verify_signature(
            :cert         => settings.get_idp_cert,
            :sig_alg      => options[:get_params]['SigAlg'],
            :signature    => options[:get_params]['Signature'],
            :query_string => query_string
          )
        else
          valid = false
          idp_certs[:signing].each do |idp_cert|
            valid = OneLogin::RubySaml::Utils.verify_signature(
              :cert         => idp_cert,
              :sig_alg      => options[:get_params]['SigAlg'],
              :signature    => options[:get_params]['Signature'],
              :query_string => query_string
            )
            if valid
              break
            end
          end
        end

        unless valid
          return append_error("Invalid Signature on Logout Request")
        end

        true
      end

    end
  end
end
