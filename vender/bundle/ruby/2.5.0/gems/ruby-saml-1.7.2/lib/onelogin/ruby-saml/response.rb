require "xml_security"
require "onelogin/ruby-saml/attributes"

require "time"
require "nokogiri"

# Only supports SAML 2.0
module OneLogin
  module RubySaml

    # SAML2 Authentication Response. SAML Response
    #
    class Response < SamlMessage
      include ErrorHandling

      ASSERTION = "urn:oasis:names:tc:SAML:2.0:assertion"
      PROTOCOL  = "urn:oasis:names:tc:SAML:2.0:protocol"
      DSIG      = "http://www.w3.org/2000/09/xmldsig#"
      XENC      = "http://www.w3.org/2001/04/xmlenc#"

      # TODO: Settings should probably be initialized too... WDYT?

      # OneLogin::RubySaml::Settings Toolkit settings
      attr_accessor :settings

      attr_reader :document
      attr_reader :decrypted_document
      attr_reader :response
      attr_reader :options

      attr_accessor :soft

      # Constructs the SAML Response. A Response Object that is an extension of the SamlMessage class.
      # @param response [String] A UUEncoded SAML response from the IdP.
      # @param options  [Hash]   :settings to provide the OneLogin::RubySaml::Settings object
      #                          Or some options for the response validation process like skip the conditions validation
      #                          with the :skip_conditions, or allow a clock_drift when checking dates with :allowed_clock_drift
      #                          or :matches_request_id that will validate that the response matches the ID of the request,
      #                          or skip the subject confirmation validation with the :skip_subject_confirmation option
      #                          or skip the recipient validation of the subject confirmation element with :skip_recipient_check option
      def initialize(response, options = {})
        raise ArgumentError.new("Response cannot be nil") if response.nil?

        @errors = []

        @options = options
        @soft = true
        unless options[:settings].nil?
          @settings = options[:settings]
          unless @settings.soft.nil?
            @soft = @settings.soft
          end
        end

        @response = decode_raw_saml(response)
        @document = XMLSecurity::SignedDocument.new(@response, @errors)

        if assertion_encrypted?
          @decrypted_document = generate_decrypted_document
        end
      end

      # Validates the SAML Response with the default values (soft = true)
      # @param collect_errors [Boolean] Stop validation when first error appears or keep validating. (if soft=true)
      # @return [Boolean] TRUE if the SAML Response is valid
      #
      def is_valid?(collect_errors = false)
        validate(collect_errors)
      end

      # @return [String] the NameID provided by the SAML response from the IdP.
      #
      def name_id
        @name_id ||= Utils.element_text(name_id_node)
      end

      alias_method :nameid, :name_id

      # @return [String] the NameID Format provided by the SAML response from the IdP.
      #
      def name_id_format
        @name_id_format ||=
          if name_id_node && name_id_node.attribute("Format")
            name_id_node.attribute("Format").value
          end
      end

      alias_method :nameid_format, :name_id_format

      # @return [String] the NameID SPNameQualifier provided by the SAML response from the IdP.
      #
      def name_id_spnamequalifier
        @name_id_spnamequalifier ||=
          if name_id_node && name_id_node.attribute("SPNameQualifier")
            name_id_node.attribute("SPNameQualifier").value
          end
      end

      # @return [String] the NameID NameQualifier provided by the SAML response from the IdP.
      #
      def name_id_namequalifier
        @name_id_namequalifier ||=
          if name_id_node && name_id_node.attribute("NameQualifier")
            name_id_node.attribute("NameQualifier").value
          end
      end

      # Gets the SessionIndex from the AuthnStatement.
      # Could be used to be stored in the local session in order
      # to be used in a future Logout Request that the SP could
      # send to the IdP, to set what specific session must be deleted
      # @return [String] SessionIndex Value
      #
      def sessionindex
        @sessionindex ||= begin
          node = xpath_first_from_signed_assertion('/a:AuthnStatement')
          node.nil? ? nil : node.attributes['SessionIndex']
        end
      end

      # Gets the Attributes from the AttributeStatement element.
      #
      # All attributes can be iterated over +attributes.each+ or returned as array by +attributes.all+
      # For backwards compatibility ruby-saml returns by default only the first value for a given attribute with
      #    attributes['name']
      # To get all of the attributes, use:
      #    attributes.multi('name')
      # Or turn off the compatibility:
      #    OneLogin::RubySaml::Attributes.single_value_compatibility = false
      # Now this will return an array:
      #    attributes['name']
      #
      # @return [Attributes] OneLogin::RubySaml::Attributes enumerable collection.
      # @raise [ValidationError] if there are 2+ Attribute with the same Name
      #
      def attributes
        @attr_statements ||= begin
          attributes = Attributes.new

          stmt_elements = xpath_from_signed_assertion('/a:AttributeStatement')
          stmt_elements.each do |stmt_element|
            stmt_element.elements.each do |attr_element|
              if attr_element.name == "EncryptedAttribute"
                node = decrypt_attribute(attr_element.dup)
              else
                node = attr_element
              end

              name  = node.attributes["Name"]

              if options[:check_duplicated_attributes] && attributes.include?(name)
                raise ValidationError.new("Found an Attribute element with duplicated Name")
              end

              values = node.elements.collect{|e|
                if (e.elements.nil? || e.elements.size == 0)
                  # SAMLCore requires that nil AttributeValues MUST contain xsi:nil XML attribute set to "true" or "1"
                  # otherwise the value is to be regarded as empty.
                  ["true", "1"].include?(e.attributes['xsi:nil']) ? nil : Utils.element_text(e)
                # explicitly support saml2:NameID with saml2:NameQualifier if supplied in attributes
                # this is useful for allowing eduPersonTargetedId to be passed as an opaque identifier to use to
                # identify the subject in an SP rather than email or other less opaque attributes
                # NameQualifier, if present is prefixed with a "/" to the value
                else
                 REXML::XPath.match(e,'a:NameID', { "a" => ASSERTION }).collect{|n|
                    (n.attributes['NameQualifier'] ? n.attributes['NameQualifier'] +"/" : '') + Utils.element_text(n)
                  }
                end
              }

              attributes.add(name, values.flatten)
            end
          end
          attributes
        end
      end

      # Gets the SessionNotOnOrAfter from the AuthnStatement.
      # Could be used to set the local session expiration (expire at latest)
      # @return [String] The SessionNotOnOrAfter value
      #
      def session_expires_at
        @expires_at ||= begin
          node = xpath_first_from_signed_assertion('/a:AuthnStatement')
          node.nil? ? nil : parse_time(node, "SessionNotOnOrAfter")
        end
      end

      # Checks if the Status has the "Success" code
      # @return [Boolean] True if the StatusCode is Sucess
      #
      def success?
        status_code == "urn:oasis:names:tc:SAML:2.0:status:Success"
      end

      # @return [String] StatusCode value from a SAML Response.
      #
      def status_code
        @status_code ||= begin
          nodes = REXML::XPath.match(
            document,
            "/p:Response/p:Status/p:StatusCode",
            { "p" => PROTOCOL }
          )
          if nodes.size == 1
            node = nodes[0]
            code = node.attributes["Value"] if node && node.attributes

            unless code == "urn:oasis:names:tc:SAML:2.0:status:Success"
              nodes = REXML::XPath.match(
                document,
                "/p:Response/p:Status/p:StatusCode/p:StatusCode",
                { "p" => PROTOCOL }
              )
              statuses = nodes.collect do |node|
                node.attributes["Value"]
              end
              extra_code = statuses.join(" | ")
              if extra_code
                code = "#{code} | #{extra_code}"
              end
            end
            code
          end
        end
      end

      # @return [String] the StatusMessage value from a SAML Response.
      #
      def status_message
        @status_message ||= begin
          nodes = REXML::XPath.match(
            document,
            "/p:Response/p:Status/p:StatusMessage",
            { "p" => PROTOCOL }
          )
          if nodes.size == 1
            Utils.element_text(nodes.first)
          end
        end
      end

      # Gets the Condition Element of the SAML Response if exists.
      # (returns the first node that matches the supplied xpath)
      # @return [REXML::Element] Conditions Element if exists
      #
      def conditions
        @conditions ||= xpath_first_from_signed_assertion('/a:Conditions')
      end

      # Gets the NotBefore Condition Element value.
      # @return [Time] The NotBefore value in Time format
      #
      def not_before
        @not_before ||= parse_time(conditions, "NotBefore")
      end

      # Gets the NotOnOrAfter Condition Element value.
      # @return [Time] The NotOnOrAfter value in Time format
      #
      def not_on_or_after
        @not_on_or_after ||= parse_time(conditions, "NotOnOrAfter")
      end

      # Gets the Issuers (from Response and Assertion).
      # (returns the first node that matches the supplied xpath from the Response and from the Assertion)
      # @return [Array] Array with the Issuers (REXML::Element)
      #
      def issuers
        @issuers ||= begin
          issuer_response_nodes = REXML::XPath.match(
            document,
            "/p:Response/a:Issuer",
            { "p" => PROTOCOL, "a" => ASSERTION }
          )

          unless issuer_response_nodes.size == 1
            error_msg = "Issuer of the Response not found or multiple."
            raise ValidationError.new(error_msg)
          end

          doc = decrypted_document.nil? ? document : decrypted_document
          issuer_assertion_nodes = xpath_from_signed_assertion("/a:Issuer")
          unless issuer_assertion_nodes.size == 1
            error_msg = "Issuer of the Assertion not found or multiple."
            raise ValidationError.new(error_msg)
          end

          nodes = issuer_response_nodes + issuer_assertion_nodes
          nodes.map { |node| Utils.element_text(node) }.compact.uniq
        end
      end

      # @return [String|nil] The InResponseTo attribute from the SAML Response.
      #
      def in_response_to
        @in_response_to ||= begin
          node = REXML::XPath.first(
            document,
            "/p:Response",
            { "p" => PROTOCOL }
          )
          node.nil? ? nil : node.attributes['InResponseTo']
        end
      end

      # @return [String|nil] Destination attribute from the SAML Response.
      #
      def destination
        @destination ||= begin
          node = REXML::XPath.first(
            document,
            "/p:Response",
            { "p" => PROTOCOL }
          )
          node.nil? ? nil : node.attributes['Destination']
        end
      end

      # @return [Array] The Audience elements from the Contitions of the SAML Response.
      #
      def audiences
        @audiences ||= begin
          nodes = xpath_from_signed_assertion('/a:Conditions/a:AudienceRestriction/a:Audience')
          nodes.map { |node| Utils.element_text(node) }.reject(&:empty?)
        end
      end

      # returns the allowed clock drift on timing validation
      # @return [Integer]
      def allowed_clock_drift
        return options[:allowed_clock_drift] || 0
      end

      private

      # Validates the SAML Response (calls several validation methods)
      # @param collect_errors [Boolean] Stop validation when first error appears or keep validating. (if soft=true)
      # @return [Boolean] True if the SAML Response is valid, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate(collect_errors = false)
        reset_errors!
        return false unless validate_response_state

        validations = [
          :validate_response_state,
          :validate_version,
          :validate_id,
          :validate_success_status,
          :validate_num_assertion,
          :validate_no_duplicated_attributes,
          :validate_signed_elements,
          :validate_structure,
          :validate_in_response_to,
          :validate_one_conditions,
          :validate_conditions,
          :validate_one_authnstatement,
          :validate_audience,
          :validate_destination,
          :validate_issuer,
          :validate_session_expiration,
          :validate_subject_confirmation,
          :validate_name_id,
          :validate_signature
        ]

        if collect_errors
          validations.each { |validation| send(validation) }
          @errors.empty?
        else
          validations.all? { |validation| send(validation) }
        end
      end


      # Validates the Status of the SAML Response
      # @return [Boolean] True if the SAML Response contains a Success code, otherwise False if soft == false
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_success_status
        return true if success?

        error_msg = 'The status code of the Response was not Success'
        status_error_msg = OneLogin::RubySaml::Utils.status_error_msg(error_msg, status_code, status_message)
        append_error(status_error_msg)
      end

      # Validates the SAML Response against the specified schema.
      # @return [Boolean] True if the XML is valid, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_structure
        structure_error_msg = "Invalid SAML Response. Not match the saml-schema-protocol-2.0.xsd"
        unless valid_saml?(document, soft)
          return append_error(structure_error_msg)
        end

        unless decrypted_document.nil?
          unless valid_saml?(decrypted_document, soft)
            return append_error(structure_error_msg)
          end
        end

        true
      end

      # Validates that the SAML Response provided in the initialization is not empty,
      # also check that the setting and the IdP cert were also provided
      # @return [Boolean] True if the required info is found, false otherwise
      #
      def validate_response_state
        return append_error("Blank response") if response.nil? || response.empty?

        return append_error("No settings on response") if settings.nil?

        if settings.idp_cert_fingerprint.nil? && settings.idp_cert.nil? && settings.idp_cert_multi.nil?
          return append_error("No fingerprint or certificate on settings")
        end

        true
      end

      # Validates that the SAML Response contains an ID
      # If fails, the error is added to the errors array.
      # @return [Boolean] True if the SAML Response contains an ID, otherwise returns False
      #
      def validate_id
        unless id(document)
          return append_error("Missing ID attribute on SAML Response")
        end

        true
      end

      # Validates the SAML version (2.0)
      # If fails, the error is added to the errors array.
      # @return [Boolean] True if the SAML Response is 2.0, otherwise returns False
      #
      def validate_version
        unless version(document) == "2.0"
          return append_error("Unsupported SAML version")
        end

        true
      end

      # Validates that the SAML Response only contains a single Assertion (encrypted or not).
      # If fails, the error is added to the errors array.
      # @return [Boolean] True if the SAML Response contains one unique Assertion, otherwise False
      #
      def validate_num_assertion
        error_msg = "SAML Response must contain 1 assertion"
        assertions = REXML::XPath.match(
          document,
          "//a:Assertion",
          { "a" => ASSERTION }
        )
        encrypted_assertions = REXML::XPath.match(
          document,
          "//a:EncryptedAssertion",
          { "a" => ASSERTION }
        )

        unless assertions.size + encrypted_assertions.size == 1
          return append_error(error_msg)
        end

        unless decrypted_document.nil?
          assertions = REXML::XPath.match(
            decrypted_document,
            "//a:Assertion",
            { "a" => ASSERTION }
          )
          unless assertions.size == 1
            return append_error(error_msg)
          end
        end

        true
      end

      # Validates that there are not duplicated attributes
      # If fails, the error is added to the errors array
      # @return [Boolean] True if there are no duplicated attribute elements, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_no_duplicated_attributes
        if options[:check_duplicated_attributes]
          begin
            attributes
          rescue ValidationError => e
            return append_error(e.message)
          end
        end

        true
      end

      # Validates the Signed elements
      # If fails, the error is added to the errors array
      # @return [Boolean] True if there is 1 or 2 Elements signed in the SAML Response
      #                                   an are a Response or an Assertion Element, otherwise False if soft=True
      #
      def validate_signed_elements
        signature_nodes = REXML::XPath.match(
          decrypted_document.nil? ? document : decrypted_document,
          "//ds:Signature",
          {"ds"=>DSIG}
        )
        signed_elements = []
        verified_seis = []
        verified_ids = []
        signature_nodes.each do |signature_node|
          signed_element = signature_node.parent.name
          if signed_element != 'Response' && signed_element != 'Assertion'
            return append_error("Invalid Signature Element '#{signed_element}'. SAML Response rejected")
          end

          if signature_node.parent.attributes['ID'].nil?
            return append_error("Signed Element must contain an ID. SAML Response rejected")
          end

          id = signature_node.parent.attributes.get_attribute("ID").value
          if verified_ids.include?(id)
            return append_error("Duplicated ID. SAML Response rejected")
          end
          verified_ids.push(id)

          # Check that reference URI matches the parent ID and no duplicate References or IDs
          ref = REXML::XPath.first(signature_node, ".//ds:Reference", {"ds"=>DSIG})
          if ref
            uri = ref.attributes.get_attribute("URI")
            if uri && !uri.value.empty?
              sei = uri.value[1..-1]

              unless sei == id
                return append_error("Found an invalid Signed Element. SAML Response rejected")
              end

              if verified_seis.include?(sei)
                return append_error("Duplicated Reference URI. SAML Response rejected")
              end

              verified_seis.push(sei)
            end
          end

          signed_elements << signed_element
        end

        unless signature_nodes.length < 3 && !signed_elements.empty?
          return append_error("Found an unexpected number of Signature Element. SAML Response rejected")
        end

        if settings.security[:want_assertions_signed] && !(signed_elements.include? "Assertion")
          return append_error("The Assertion of the Response is not signed and the SP requires it")
        end

        true
      end

      # Validates if the provided request_id match the inResponseTo value.
      # If fails, the error is added to the errors array
      # @return [Boolean] True if there is no request_id or it match, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_in_response_to
        return true unless options.has_key? :matches_request_id
        return true if options[:matches_request_id].nil?
        return true unless options[:matches_request_id] != in_response_to

        error_msg = "The InResponseTo of the Response: #{in_response_to}, does not match the ID of the AuthNRequest sent by the SP: #{options[:matches_request_id]}"
        append_error(error_msg)
      end

      # Validates the Audience, (If the Audience match the Service Provider EntityID)
      # If fails, the error is added to the errors array
      # @return [Boolean] True if there is an Audience Element that match the Service Provider EntityID, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_audience
        return true if audiences.empty? || settings.issuer.nil? || settings.issuer.empty?

        unless audiences.include? settings.issuer
          error_msg = "#{settings.issuer} is not a valid audience for this Response - Valid audiences: #{audiences.join(',')}"
          return append_error(error_msg)
        end

        true
      end

      # Validates the Destination, (If the SAML Response is received where expected).
      # If the response was initialized with the :skip_destination option, this validation is skipped,
      # If fails, the error is added to the errors array
      # @return [Boolean] True if there is a Destination element that matches the Consumer Service URL, otherwise False
      #
      def validate_destination
        return true if destination.nil?
        return true if options[:skip_destination]

        if destination.empty?
          error_msg = "The response has an empty Destination value"
          return append_error(error_msg)
        end

        return true if settings.assertion_consumer_service_url.nil? || settings.assertion_consumer_service_url.empty?

        unless OneLogin::RubySaml::Utils.uri_match?(destination, settings.assertion_consumer_service_url)
          error_msg = "The response was received at #{destination} instead of #{settings.assertion_consumer_service_url}"
          return append_error(error_msg)
        end

        true
      end

      # Checks that the samlp:Response/saml:Assertion/saml:Conditions element exists and is unique.
      # If fails, the error is added to the errors array
      # @return [Boolean] True if there is a conditions element and is unique
      #
      def validate_one_conditions
        conditions_nodes = xpath_from_signed_assertion('/a:Conditions')
        unless conditions_nodes.size == 1
          error_msg = "The Assertion must include one Conditions element"
          return append_error(error_msg)
        end

        true
      end

      # Checks that the samlp:Response/saml:Assertion/saml:AuthnStatement element exists and is unique.
      # If fails, the error is added to the errors array
      # @return [Boolean] True if there is a authnstatement element and is unique
      #
      def validate_one_authnstatement
        authnstatement_nodes = xpath_from_signed_assertion('/a:AuthnStatement')
        unless authnstatement_nodes.size == 1
          error_msg = "The Assertion must include one AuthnStatement element"
          return append_error(error_msg)
        end

        true
      end

      # Validates the Conditions. (If the response was initialized with the :skip_conditions option, this validation is skipped,
      # If the response was initialized with the :allowed_clock_drift option, the timing validations are relaxed by the allowed_clock_drift value)
      # @return [Boolean] True if satisfies the conditions, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_conditions
        return true if conditions.nil?
        return true if options[:skip_conditions]

        now = Time.now.utc

        if not_before && (now_with_drift = now + allowed_clock_drift) < not_before
          error_msg = "Current time is earlier than NotBefore condition (#{now_with_drift} < #{not_before})"
          return append_error(error_msg)
        end

        if not_on_or_after && now >= (not_on_or_after_with_drift = not_on_or_after + allowed_clock_drift)
          error_msg = "Current time is on or after NotOnOrAfter condition (#{now} >= #{not_on_or_after_with_drift})"
          return append_error(error_msg)
        end

        true
      end

      # Validates the Issuer (Of the SAML Response and the SAML Assertion)
      # @param soft [Boolean] soft Enable or Disable the soft mode (In order to raise exceptions when the response is invalid or not)
      # @return [Boolean] True if the Issuer matchs the IdP entityId, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_issuer
        return true if settings.idp_entity_id.nil?

        begin
          obtained_issuers = issuers
        rescue ValidationError => e
          return append_error(e.message)
        end

        obtained_issuers.each do |issuer|
          unless OneLogin::RubySaml::Utils.uri_match?(issuer, settings.idp_entity_id)
            error_msg = "Doesn't match the issuer, expected: <#{settings.idp_entity_id}>, but was: <#{issuer}>"
            return append_error(error_msg)
          end
        end

        true
      end

      # Validates that the Session haven't expired (If the response was initialized with the :allowed_clock_drift option,
      # this time validation is relaxed by the allowed_clock_drift value)
      # If fails, the error is added to the errors array
      # @param soft [Boolean] soft Enable or Disable the soft mode (In order to raise exceptions when the response is invalid or not)
      # @return [Boolean] True if the SessionNotOnOrAfter of the AttributeStatement is valid, otherwise (when expired) False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_session_expiration(soft = true)
        return true if session_expires_at.nil?

        now = Time.now.utc
        unless (session_expires_at + allowed_clock_drift) > now
          error_msg = "The attributes have expired, based on the SessionNotOnOrAfter of the AttributeStatement of this Response"
          return append_error(error_msg)
        end

        true
      end

      # Validates if exists valid SubjectConfirmation (If the response was initialized with the :allowed_clock_drift option,
      # timimg validation are relaxed by the allowed_clock_drift value. If the response was initialized with the
      # :skip_subject_confirmation option, this validation is skipped)
      # There is also an optional Recipient check
      # If fails, the error is added to the errors array
      # @return [Boolean] True if exists a valid SubjectConfirmation, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_subject_confirmation
        return true if options[:skip_subject_confirmation]
        valid_subject_confirmation = false

        subject_confirmation_nodes = xpath_from_signed_assertion('/a:Subject/a:SubjectConfirmation')

        now = Time.now.utc
        subject_confirmation_nodes.each do |subject_confirmation|
          if subject_confirmation.attributes.include? "Method" and subject_confirmation.attributes['Method'] != 'urn:oasis:names:tc:SAML:2.0:cm:bearer'
            next
          end

          confirmation_data_node = REXML::XPath.first(
            subject_confirmation,
            'a:SubjectConfirmationData',
            { "a" => ASSERTION }
          )

          next unless confirmation_data_node

          attrs = confirmation_data_node.attributes
          next if (attrs.include? "InResponseTo" and attrs['InResponseTo'] != in_response_to) ||
                  (attrs.include? "NotOnOrAfter" and (parse_time(confirmation_data_node, "NotOnOrAfter") + allowed_clock_drift) <= now) ||
                  (attrs.include? "NotBefore" and parse_time(confirmation_data_node, "NotBefore") > (now + allowed_clock_drift)) ||
                  (attrs.include? "Recipient" and !options[:skip_recipient_check] and settings and attrs['Recipient'] != settings.assertion_consumer_service_url)

          valid_subject_confirmation = true
          break
        end

        if !valid_subject_confirmation
          error_msg = "A valid SubjectConfirmation was not found on this Response"
          return append_error(error_msg)
        end

        true
      end

      # Validates the NameID element
      def validate_name_id
        if name_id_node.nil?
          if settings.security[:want_name_id]
            return append_error("No NameID element found in the assertion of the Response")
          end
        else
          if name_id.nil? || name_id.empty?
            return append_error("An empty NameID value found")
          end

          unless settings.issuer.nil? || settings.issuer.empty? || name_id_spnamequalifier.nil? || name_id_spnamequalifier.empty?
            if name_id_spnamequalifier != settings.issuer
              return append_error("The SPNameQualifier value mistmatch the SP entityID value.")
            end
          end
        end

        true
      end

      # Validates the Signature
      # @return [Boolean] True if not contains a Signature or if the Signature is valid, otherwise False if soft=True
      # @raise [ValidationError] if soft == false and validation fails
      #
      def validate_signature
        error_msg = "Invalid Signature on SAML Response"

        # If the response contains the signature, and the assertion was encrypted, validate the original SAML Response
        # otherwise, review if the decrypted assertion contains a signature
        sig_elements = REXML::XPath.match(
          document,
          "/p:Response[@ID=$id]/ds:Signature]",
          { "p" => PROTOCOL, "ds" => DSIG },
          { 'id' => document.signed_element_id }
        )

        use_original = sig_elements.size == 1 || decrypted_document.nil?
        doc = use_original ? document : decrypted_document

        # Check signature nodes
        if sig_elements.nil? || sig_elements.size == 0
          sig_elements = REXML::XPath.match(
            doc,
            "/p:Response/a:Assertion[@ID=$id]/ds:Signature",
            {"p" => PROTOCOL, "a" => ASSERTION, "ds"=>DSIG},
            { 'id' => doc.signed_element_id }
          )
        end

        if sig_elements.size != 1
          return append_error(error_msg)
        end

        idp_certs = settings.get_idp_cert_multi
        if idp_certs.nil? || idp_certs[:signing].empty?
          opts = {}
          opts[:fingerprint_alg] = settings.idp_cert_fingerprint_algorithm
          opts[:cert] = settings.get_idp_cert
          fingerprint = settings.get_fingerprint

          unless fingerprint && doc.validate_document(fingerprint, @soft, opts)
            return append_error(error_msg)
          end
        else
          valid = false
          idp_certs[:signing].each do |idp_cert|
            valid = doc.validate_document_with_cert(idp_cert)
            if valid
              break
            end
          end
          unless valid
            return append_error(error_msg)
          end
        end

        true
      end

      def name_id_node
        @name_id_node ||=
          begin
            encrypted_node = xpath_first_from_signed_assertion('/a:Subject/a:EncryptedID')
            if encrypted_node
              node = decrypt_nameid(encrypted_node)
            else
              node = xpath_first_from_signed_assertion('/a:Subject/a:NameID')
            end
          end
      end

      # Extracts the first appearance that matchs the subelt (pattern)
      # Search on any Assertion that is signed, or has a Response parent signed
      # @param subelt [String] The XPath pattern
      # @return [REXML::Element | nil] If any matches, return the Element
      #
      def xpath_first_from_signed_assertion(subelt=nil)
        doc = decrypted_document.nil? ? document : decrypted_document
        node = REXML::XPath.first(
            doc,
            "/p:Response/a:Assertion[@ID=$id]#{subelt}",
            { "p" => PROTOCOL, "a" => ASSERTION },
            { 'id' => doc.signed_element_id }
        )
        node ||= REXML::XPath.first(
            doc,
            "/p:Response[@ID=$id]/a:Assertion#{subelt}",
            { "p" => PROTOCOL, "a" => ASSERTION },
            { 'id' => doc.signed_element_id }
        )
        node
      end

      # Extracts all the appearances that matchs the subelt (pattern)
      # Search on any Assertion that is signed, or has a Response parent signed
      # @param subelt [String] The XPath pattern
      # @return [Array of REXML::Element] Return all matches
      #
      def xpath_from_signed_assertion(subelt=nil)
        doc = decrypted_document.nil? ? document : decrypted_document
        node = REXML::XPath.match(
            doc,
            "/p:Response/a:Assertion[@ID=$id]#{subelt}",
            { "p" => PROTOCOL, "a" => ASSERTION },
            { 'id' => doc.signed_element_id }
        )
        node.concat( REXML::XPath.match(
            doc,
            "/p:Response[@ID=$id]/a:Assertion#{subelt}",
            { "p" => PROTOCOL, "a" => ASSERTION },
            { 'id' => doc.signed_element_id }
        ))
      end

      # Generates the decrypted_document
      # @return [XMLSecurity::SignedDocument] The SAML Response with the assertion decrypted
      #
      def generate_decrypted_document
        if settings.nil? || !settings.get_sp_key
          raise ValidationError.new('An EncryptedAssertion found and no SP private key found on the settings to decrypt it. Be sure you provided the :settings parameter at the initialize method')
        end

        # Marshal at Ruby 1.8.7 throw an Exception
        if RUBY_VERSION < "1.9"
          document_copy = XMLSecurity::SignedDocument.new(response, errors)
        else
          document_copy = Marshal.load(Marshal.dump(document))
        end

        decrypt_assertion_from_document(document_copy)
      end

      # Obtains a SAML Response with the EncryptedAssertion element decrypted
      # @param document_copy [XMLSecurity::SignedDocument] A copy of the original SAML Response with the encrypted assertion
      # @return [XMLSecurity::SignedDocument] The SAML Response with the assertion decrypted
      #
      def decrypt_assertion_from_document(document_copy)
        response_node = REXML::XPath.first(
          document_copy,
          "/p:Response/",
          { "p" => PROTOCOL }
        )
        encrypted_assertion_node = REXML::XPath.first(
          document_copy,
          "(/p:Response/EncryptedAssertion/)|(/p:Response/a:EncryptedAssertion/)",
          { "p" => PROTOCOL, "a" => ASSERTION }
        )
        response_node.add(decrypt_assertion(encrypted_assertion_node))
        encrypted_assertion_node.remove
        XMLSecurity::SignedDocument.new(response_node.to_s)
      end

      # Checks if the SAML Response contains or not an EncryptedAssertion element
      # @return [Boolean] True if the SAML Response contains an EncryptedAssertion element
      #
      def assertion_encrypted?
        ! REXML::XPath.first(
          document,
          "(/p:Response/EncryptedAssertion/)|(/p:Response/a:EncryptedAssertion/)",
          { "p" => PROTOCOL, "a" => ASSERTION }
        ).nil?
      end

      # Decrypts an EncryptedAssertion element
      # @param encrypted_assertion_node [REXML::Element] The EncryptedAssertion element
      # @return [REXML::Document] The decrypted EncryptedAssertion element
      #
      def decrypt_assertion(encrypted_assertion_node)
        decrypt_element(encrypted_assertion_node, /(.*<\/(\w+:)?Assertion>)/m)
      end

      # Decrypts an EncryptedID element
      # @param encryptedid_node [REXML::Element] The EncryptedID element
      # @return [REXML::Document] The decrypted EncrypedtID element
      #
      def decrypt_nameid(encryptedid_node)
        decrypt_element(encryptedid_node, /(.*<\/(\w+:)?NameID>)/m)
      end

      # Decrypts an EncryptedID element
      # @param encryptedid_node [REXML::Element] The EncryptedID element
      # @return [REXML::Document] The decrypted EncrypedtID element
      #
      def decrypt_attribute(encryptedattribute_node)
        decrypt_element(encryptedattribute_node, /(.*<\/(\w+:)?Attribute>)/m)
      end

      # Decrypt an element
      # @param encryptedid_node [REXML::Element] The encrypted element
      # @param rgrex string Regex
      # @return [REXML::Document] The decrypted element
      #
      def decrypt_element(encrypt_node, rgrex)
        if settings.nil? || !settings.get_sp_key
          raise ValidationError.new('An ' + encrypt_node.name + ' found and no SP private key found on the settings to decrypt it')
        end


        if encrypt_node.name == 'EncryptedAttribute'
          node_header = '<node xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        else
          node_header = '<node xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">'
        end

        elem_plaintext = OneLogin::RubySaml::Utils.decrypt_data(encrypt_node, settings.get_sp_key)
        # If we get some problematic noise in the plaintext after decrypting.
        # This quick regexp parse will grab only the Element and discard the noise.
        elem_plaintext = elem_plaintext.match(rgrex)[0]

        # To avoid namespace errors if saml namespace is not defined
        # create a parent node first with the namespace defined
        elem_plaintext = node_header + elem_plaintext + '</node>'
        doc = REXML::Document.new(elem_plaintext)
        doc.root[0]
      end

      # Parse the attribute of a given node in Time format
      # @param node [REXML:Element] The node
      # @param attribute [String] The attribute name
      # @return [Time|nil] The parsed value
      #
      def parse_time(node, attribute)
        if node && node.attributes[attribute]
          Time.parse(node.attributes[attribute])
        end
      end
    end
  end
end
