require "uri"

require "onelogin/ruby-saml/logging"
require "onelogin/ruby-saml/utils"

# Only supports SAML 2.0
module OneLogin
  module RubySaml

    # SAML2 Metadata. XML Metadata Builder
    #
    class Metadata

      # Return SP metadata based on the settings.
      # @param settings [OneLogin::RubySaml::Settings|nil] Toolkit settings
      # @param pretty_print [Boolean] Pretty print or not the response
      #                               (No pretty print if you gonna validate the signature)
      # @return [String] XML Metadata of the Service Provider
      #
      def generate(settings, pretty_print=false)
        meta_doc = XMLSecurity::Document.new
        namespaces = {
            "xmlns:md" => "urn:oasis:names:tc:SAML:2.0:metadata"
        }
        if settings.attribute_consuming_service.configured?
          namespaces["xmlns:saml"] = "urn:oasis:names:tc:SAML:2.0:assertion"
        end
        root = meta_doc.add_element "md:EntityDescriptor", namespaces
        sp_sso = root.add_element "md:SPSSODescriptor", {
            "protocolSupportEnumeration" => "urn:oasis:names:tc:SAML:2.0:protocol",
            "AuthnRequestsSigned" => settings.security[:authn_requests_signed],
            "WantAssertionsSigned" => settings.security[:want_assertions_signed],
        }

        # Add KeyDescriptor if messages will be signed / encrypted
        # with SP certificate, and new SP certificate if any
        cert = settings.get_sp_cert
        cert_new = settings.get_sp_cert_new

        for sp_cert in [cert, cert_new]
          if sp_cert
            cert_text = Base64.encode64(sp_cert.to_der).gsub("\n", '')
            kd = sp_sso.add_element "md:KeyDescriptor", { "use" => "signing" }
            ki = kd.add_element "ds:KeyInfo", {"xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#"}
            xd = ki.add_element "ds:X509Data"
            xc = xd.add_element "ds:X509Certificate"
            xc.text = cert_text

            if settings.security[:want_assertions_encrypted]
              kd2 = sp_sso.add_element "md:KeyDescriptor", { "use" => "encryption" }
              ki2 = kd2.add_element "ds:KeyInfo", {"xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#"}
              xd2 = ki2.add_element "ds:X509Data"
              xc2 = xd2.add_element "ds:X509Certificate"
              xc2.text = cert_text
            end
          end
        end

        root.attributes["ID"] = OneLogin::RubySaml::Utils.uuid
        if settings.issuer
          root.attributes["entityID"] = settings.issuer
        end
        if settings.single_logout_service_url
          sp_sso.add_element "md:SingleLogoutService", {
              "Binding" => settings.single_logout_service_binding,
              "Location" => settings.single_logout_service_url,
              "ResponseLocation" => settings.single_logout_service_url
          }
        end
        if settings.name_identifier_format
          nameid = sp_sso.add_element "md:NameIDFormat"
          nameid.text = settings.name_identifier_format
        end
        if settings.assertion_consumer_service_url
          sp_sso.add_element "md:AssertionConsumerService", {
              "Binding" => settings.assertion_consumer_service_binding,
              "Location" => settings.assertion_consumer_service_url,
              "isDefault" => true,
              "index" => 0
          }
        end

        if settings.attribute_consuming_service.configured?
          sp_acs = sp_sso.add_element "md:AttributeConsumingService", {
            "isDefault" => "true",
            "index" => settings.attribute_consuming_service.index
          }
          srv_name = sp_acs.add_element "md:ServiceName", {
            "xml:lang" => "en"
          }
          srv_name.text = settings.attribute_consuming_service.name
          settings.attribute_consuming_service.attributes.each do |attribute|
            sp_req_attr = sp_acs.add_element "md:RequestedAttribute", {
              "NameFormat" => attribute[:name_format],
              "Name" => attribute[:name],
              "FriendlyName" => attribute[:friendly_name],
              "isRequired" => attribute[:is_required] || false
            }
            unless attribute[:attribute_value].nil?
              Array(attribute[:attribute_value]).each do |value|
                sp_attr_val = sp_req_attr.add_element "saml:AttributeValue"
                sp_attr_val.text = value.to_s
              end
            end
          end
        end

        # With OpenSSO, it might be required to also include
        #  <md:RoleDescriptor xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:query="urn:oasis:names:tc:SAML:metadata:ext:query" xsi:type="query:AttributeQueryDescriptorType" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"/>
        #  <md:XACMLAuthzDecisionQueryDescriptor WantAssertionsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"/>

        meta_doc << REXML::XMLDecl.new("1.0", "UTF-8")

        # embed signature
        if settings.security[:metadata_signed] && settings.private_key && settings.certificate
          private_key = settings.get_sp_key
          meta_doc.sign_document(private_key, cert, settings.security[:signature_method], settings.security[:digest_method])
        end

        ret = ""
        # pretty print the XML so IdP administrators can easily see what the SP supports
        if pretty_print
          meta_doc.write(ret, 1)
        else
          ret = meta_doc.to_s
        end

        return ret
      end
    end
  end
end
