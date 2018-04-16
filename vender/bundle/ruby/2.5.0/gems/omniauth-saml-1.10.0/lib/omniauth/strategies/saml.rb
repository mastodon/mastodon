require 'omniauth'
require 'ruby-saml'

module OmniAuth
  module Strategies
    class SAML
      include OmniAuth::Strategy

      def self.inherited(subclass)
        OmniAuth::Strategy.included(subclass)
      end

      OTHER_REQUEST_OPTIONS = [:skip_conditions, :allowed_clock_drift, :matches_request_id, :skip_subject_confirmation].freeze

      option :name_identifier_format, nil
      option :idp_sso_target_url_runtime_params, {}
      option :request_attributes, [
        { :name => 'email', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Email address' },
        { :name => 'name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Full name' },
        { :name => 'first_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Given name' },
        { :name => 'last_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Family name' }
      ]
      option :attribute_service_name, 'Required attributes'
      option :attribute_statements, {
        name: ["name"],
        email: ["email", "mail"],
        first_name: ["first_name", "firstname", "firstName"],
        last_name: ["last_name", "lastname", "lastName"]
      }
      option :slo_default_relay_state
      option :uid_attribute
      option :idp_slo_session_destroy, proc { |_env, session| session.clear }

      def request_phase
        authn_request = OneLogin::RubySaml::Authrequest.new

        with_settings do |settings|
          redirect(authn_request.create(settings, additional_params_for_authn_request))
        end
      end

      def callback_phase
        raise OmniAuth::Strategies::SAML::ValidationError.new("SAML response missing") unless request.params["SAMLResponse"]

        with_settings do |settings|
          # Call a fingerprint validation method if there's one
          validate_fingerprint(settings) if options.idp_cert_fingerprint_validator

          handle_response(request.params["SAMLResponse"], options_for_response_object, settings) do
            super
          end
        end
      rescue OmniAuth::Strategies::SAML::ValidationError
        fail!(:invalid_ticket, $!)
      rescue OneLogin::RubySaml::ValidationError
        fail!(:invalid_ticket, $!)
      end

      # Obtain an idp certificate fingerprint from the response.
      def response_fingerprint
        response = request.params["SAMLResponse"]
        response = (response =~ /^</) ? response : Base64.decode64(response)
        document = XMLSecurity::SignedDocument::new(response)
        cert_element = REXML::XPath.first(document, "//ds:X509Certificate", { "ds"=> 'http://www.w3.org/2000/09/xmldsig#' })
        base64_cert = cert_element.text
        cert_text = Base64.decode64(base64_cert)
        cert = OpenSSL::X509::Certificate.new(cert_text)
        Digest::SHA1.hexdigest(cert.to_der).upcase.scan(/../).join(':')
      end

      def other_phase
        if request_path_pattern.match(current_path)
          @env['omniauth.strategy'] ||= self
          setup_phase

          if on_subpath?(:metadata)
            other_phase_for_metadata
          elsif on_subpath?(:slo)
            other_phase_for_slo
          elsif on_subpath?(:spslo)
            other_phase_for_spslo
          else
            call_app!
          end
        else
          call_app!
        end
      end

      uid do
        if options.uid_attribute
          ret = find_attribute_by([options.uid_attribute])
          if ret.nil?
            raise OmniAuth::Strategies::SAML::ValidationError.new("SAML response missing '#{options.uid_attribute}' attribute")
          end
          ret
        else
          @name_id
        end
      end

      info do
        found_attributes = options.attribute_statements.map do |key, values|
          attribute = find_attribute_by(values)
          [key, attribute]
        end

        Hash[found_attributes]
      end

      extra { { :raw_info => @attributes, :session_index => @session_index, :response_object =>  @response_object } }

      def find_attribute_by(keys)
        keys.each do |key|
          return @attributes[key] if @attributes[key]
        end

        nil
      end

      private

      def request_path_pattern
        @request_path_pattern ||= %r{\A#{Regexp.quote(request_path)}(/|\z)}
      end

      def on_subpath?(subpath)
        on_path?("#{request_path}/#{subpath}")
      end

      def handle_response(raw_response, opts, settings)
        response = OneLogin::RubySaml::Response.new(raw_response, opts.merge(settings: settings))
        response.attributes["fingerprint"] = settings.idp_cert_fingerprint
        response.soft = false

        response.is_valid?
        @name_id = response.name_id
        @session_index = response.sessionindex
        @attributes = response.attributes
        @response_object = response

        session["saml_uid"] = @name_id
        session["saml_session_index"] = @session_index
        yield
      end

      def slo_relay_state
        if request.params.has_key?("RelayState") && request.params["RelayState"] != ""
          request.params["RelayState"]
        else
          slo_default_relay_state = options.slo_default_relay_state
          if slo_default_relay_state.respond_to?(:call)
            if slo_default_relay_state.arity == 1
              slo_default_relay_state.call(request)
            else
              slo_default_relay_state.call
            end
          else
            slo_default_relay_state
          end
        end
      end

      def handle_logout_response(raw_response, settings)
        # After sending an SP initiated LogoutRequest to the IdP, we need to accept
        # the LogoutResponse, verify it, then actually delete our session.

        logout_response = OneLogin::RubySaml::Logoutresponse.new(raw_response, settings, :matches_request_id => session["saml_transaction_id"])
        logout_response.soft = false
        logout_response.validate

        session.delete("saml_uid")
        session.delete("saml_transaction_id")
        session.delete("saml_session_index")

        redirect(slo_relay_state)
      end

      def handle_logout_request(raw_request, settings)
        logout_request = OneLogin::RubySaml::SloLogoutrequest.new(raw_request)

        if logout_request.is_valid? &&
          logout_request.name_id == session["saml_uid"]

          # Actually log out this session
          options[:idp_slo_session_destroy].call @env, session

          # Generate a response to the IdP.
          logout_request_id = logout_request.id
          logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(settings, logout_request_id, nil, RelayState: slo_relay_state)
          redirect(logout_response)
        else
          raise OmniAuth::Strategies::SAML::ValidationError.new("SAML failed to process LogoutRequest")
        end
      end

      # Create a SP initiated SLO: https://github.com/onelogin/ruby-saml#single-log-out
      def generate_logout_request(settings)
        logout_request = OneLogin::RubySaml::Logoutrequest.new()

        # Since we created a new SAML request, save the transaction_id
        # to compare it with the response we get back
        session["saml_transaction_id"] = logout_request.uuid

        if settings.name_identifier_value.nil?
          settings.name_identifier_value = session["saml_uid"]
        end

        if settings.sessionindex.nil?
          settings.sessionindex = session["saml_session_index"]
        end

        logout_request.create(settings, RelayState: slo_relay_state)
      end

      def with_settings
        options[:assertion_consumer_service_url] ||= callback_url
        yield OneLogin::RubySaml::Settings.new(options)
      end

      def validate_fingerprint(settings)
        fingerprint_exists = options.idp_cert_fingerprint_validator[response_fingerprint]

        unless fingerprint_exists
          raise OmniAuth::Strategies::SAML::ValidationError.new("Non-existent fingerprint")
        end

        # id_cert_fingerprint becomes the given fingerprint if it exists
        settings.idp_cert_fingerprint = fingerprint_exists
      end

      def options_for_response_object
        # filter options to select only extra parameters
        opts = options.select {|k,_| OTHER_REQUEST_OPTIONS.include?(k.to_sym)}

        # symbolize keys without activeSupport/symbolize_keys (ruby-saml use symbols)
        opts.inject({}) do |new_hash, (key, value)|
          new_hash[key.to_sym] = value
          new_hash
        end
      end

      def other_phase_for_metadata
        with_settings do |settings|
          # omniauth does not set the strategy on the other_phase
          response = OneLogin::RubySaml::Metadata.new

          add_request_attributes_to(settings) if options.request_attributes.length > 0

          Rack::Response.new(response.generate(settings), 200, { "Content-Type" => "application/xml" }).finish
        end
      end

      def other_phase_for_slo
        with_settings do |settings|
          if request.params["SAMLResponse"]
            handle_logout_response(request.params["SAMLResponse"], settings)
          elsif request.params["SAMLRequest"]
            handle_logout_request(request.params["SAMLRequest"], settings)
          else
            raise OmniAuth::Strategies::SAML::ValidationError.new("SAML logout response/request missing")
          end
        end
      end

      def other_phase_for_spslo
        if options.idp_slo_target_url
          with_settings do |settings|
            redirect(generate_logout_request(settings))
          end
        else
          Rack::Response.new("Not Implemented", 501, { "Content-Type" => "text/html" }).finish
        end
      end

      def add_request_attributes_to(settings)
        settings.attribute_consuming_service.service_name options.attribute_service_name
        settings.issuer = options.issuer

        options.request_attributes.each do |attribute|
          settings.attribute_consuming_service.add_attribute attribute
        end
      end

      def additional_params_for_authn_request
        {}.tap do |additional_params|
          runtime_request_parameters = options.delete(:idp_sso_target_url_runtime_params)

          if runtime_request_parameters
            runtime_request_parameters.each_pair do |request_param_key, mapped_param_key|
              additional_params[mapped_param_key] = request.params[request_param_key.to_s] if request.params.has_key?(request_param_key.to_s)
            end
          end
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'saml', 'SAML'
