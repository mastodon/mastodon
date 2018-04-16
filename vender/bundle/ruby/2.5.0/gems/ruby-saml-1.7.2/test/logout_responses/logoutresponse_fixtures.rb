#encoding: utf-8

def default_logout_response_opts
  {
      :uuid => "_28024690-000e-0130-b6d2-38f6b112be8b",
      :issue_instant => Time.now.strftime('%Y-%m-%dT%H:%M:%SZ'),
      :settings => settings
  }
end

def valid_logout_response_document(opts = {})
  opts = default_logout_response_opts.merge(opts)

  "<samlp:LogoutResponse
        xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\"
        ID=\"#{random_id}\" Version=\"2.0\"
        IssueInstant=\"#{opts[:issue_instant]}\"
        Destination=\"#{opts[:settings].single_logout_service_url}\"
        InResponseTo=\"#{opts[:uuid]}\">
      <saml:Issuer xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\">#{opts[:settings].issuer}</saml:Issuer>
      <samlp:Status xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\">
      <samlp:StatusCode xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\"
          Value=\"urn:oasis:names:tc:SAML:2.0:status:Success\">
      </samlp:StatusCode>
      </samlp:Status>
      </samlp:LogoutResponse>"
end

def unsuccessful_logout_response_document(opts = {})
  opts = default_logout_response_opts.merge(opts)

  "<samlp:LogoutResponse
        xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\"
        ID=\"#{random_id}\" Version=\"2.0\"
        IssueInstant=\"#{opts[:issue_instant]}\"
        Destination=\"#{opts[:settings].single_logout_service_url}\"
        InResponseTo=\"#{opts[:uuid]}\">
      <saml:Issuer xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\">#{opts[:settings].issuer}</saml:Issuer>
      <samlp:Status xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\">
      <samlp:StatusCode xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\"
          Value=\"urn:oasis:names:tc:SAML:2.0:status:Requester\">
      </samlp:StatusCode>
      </samlp:Status>
      </samlp:LogoutResponse>"
end

def invalid_xml_logout_response_document
  "<samlp:SomethingAwful
        xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\"
        ID=\"#{random_id}\" Version=\"2.0\">
      </samlp:SomethingAwful>"
end

def settings
  @settings ||= OneLogin::RubySaml::Settings.new(
      {
          :assertion_consumer_service_url => "http://app.muda.no/sso/consume",
          :single_logout_service_url => "http://app.muda.no/sso/consume_logout",
          :issuer => "http://app.muda.no",
          :sp_name_qualifier => "http://sso.muda.no",
          :idp_sso_target_url => "http://sso.muda.no/sso",
          :idp_slo_target_url => "http://sso.muda.no/slo",
          :idp_cert_fingerprint => "00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00",
          :name_identifier_format => "urn:oasis:names:tc:SAML:2.0:nameid-format:transient",
      }
  )
end
