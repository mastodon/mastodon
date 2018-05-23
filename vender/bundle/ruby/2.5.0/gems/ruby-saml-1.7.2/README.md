# Ruby SAML [![Build Status](https://secure.travis-ci.org/onelogin/ruby-saml.svg)](http://travis-ci.org/onelogin/ruby-saml) [![Coverage Status](https://coveralls.io/repos/onelogin/ruby-saml/badge.svg?branch=master%0A)](https://coveralls.io/r/onelogin/ruby-saml?branch=master%0A) [![Gem Version](https://badge.fury.io/rb/ruby-saml.svg)](http://badge.fury.io/rb/ruby-saml)

## Updating from 1.6.0 to 1.7.0

Version `1.7.0` is a recommended update for all Ruby SAML users as it includes a fix for the [CVE-2017-11428](https://www.cvedetails.com/cve/CVE-2017-11428/) vulnerability.

## Updating from 1.5.0 to 1.6.0

Version `1.6.0` changes the preferred way to construct instances of `Logoutresponse` and `SloLogoutrequest`. Previously the _SAMLResponse_, _RelayState_, and _SigAlg_ parameters of these message types were provided via the constructor's `options[:get_params]` parameter. Unfortunately this can result in incompatibility with other SAML implementations; signatures are specified to be computed based on the _sender's_ URI-encoding of the message, which can differ from that of Ruby SAML. In particular, Ruby SAML's URI-encoding does not match that of Microsoft ADFS, so messages from ADFS can fail signature validation.

The new preferred way to provide _SAMLResponse_, _RelayState_, and _SigAlg_ is via the `options[:raw_get_params]` parameter. For example:

```ruby
# In this example `query_params` is assumed to contain decoded query parameters,
# and `raw_query_params` is assumed to contain encoded query parameters as sent by the IDP.
settings = {
  settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1
  settings.soft = false
}
options = {
  get_params: {
    "Signature" => query_params["Signature"],
  },
  raw_get_params: {
    "SAMLRequest" => raw_query_params["SAMLRequest"],
    "SigAlg" => raw_query_params["SigAlg"],
    "RelayState" => raw_query_params["RelayState"],
  },
}
slo_logout_request = OneLogin::RubySaml::SloLogoutrequest.new(query_params["SAMLRequest"], settings, options)
raise "Invalid Logout Request" unless slo_logout_request.is_valid?
```

The old form is still supported for backward compatibility, but all Ruby SAML users should prefer `options[:raw_get_params]` where possible to ensure compatibility with other SAML implementations.

## Updating from 1.4.2 to 1.4.3

Version `1.4.3` introduces Recipient validation of SubjectConfirmation elements.
The 'Recipient' value is compared with the settings.assertion_consumer_service_url
value.
If you want to skip that validation, add the :skip_recipient_check option to the
initialize method of the Response object.

## Updating from 1.3.x to 1.4.X

Version `1.4.0` is a recommended update for all Ruby SAML users as it includes security improvements.

## Updating from 1.2.x to 1.3.X

Version `1.3.0` is a recommended update for all Ruby SAML users as it includes security fixes. It  adds security improvements in order to prevent Signature wrapping attacks. [CVE-2016-5697](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-5697)

## Updating from 1.1.x to 1.2.X

Version `1.2` adds IDP metadata parsing improvements, uuid deprecation in favour of SecureRandom, refactor error handling and some minor improvements

There is no compatibility issue detected.

For more details, please review [the changelog](changelog.md).

## Updating from 1.0.x to 1.1.X

Version `1.1` adds some improvements on signature validation and solves some namespace conflicts.

## Updating from 0.9.x to 1.0.X

Version `1.0` is a recommended update for all Ruby SAML users as it includes security fixes.

Version `1.0` adds security improvements like entity expansion limitation, more SAML message validations, and other important improvements like decrypt support.

### Important Changes
Please note the `get_idp_metadata` method raises an exception when it is not able to fetch the idp metadata, so review your integration if you are using this functionality.

## Updating from 0.8.x to 0.9.x
Version `0.9` adds many new features and improvements.

## Updating from 0.7.x to 0.8.x
Version `0.8.x` changes the namespace of the gem from `OneLogin::Saml` to `OneLogin::RubySaml`.  Please update your implementations of the gem accordingly.

## Overview

The Ruby SAML library is for implementing the client side of a SAML authorization, i.e. it provides a means for managing authorization initialization and confirmation requests from identity providers.

SAML authorization is a two step process and you are expected to implement support for both.

We created a demo project for Rails4 that uses the latest version of this library: [ruby-saml-example](https://github.com/onelogin/ruby-saml-example)

### Supported versions of Ruby
* 1.8.7
* 1.9.x
* 2.0.x
* 2.1.x
* 2.2.x
* 2.3.x
* 2.4.x
* JRuby 1.7.19
* JRuby 9.0.0.0

## Adding Features, Pull Requests
* Fork the repository
* Make your feature addition or bug fix
* Add tests for your new features. This is important so we don't break any features in a future version unintentionally.
* Ensure all tests pass.
* Do not change rakefile, version, or history.
* Open a pull request, following [this template](https://gist.github.com/Lordnibbler/11002759).

## Security Guidelines

If you believe you have discovered a security vulnerability in this gem, please report it at https://www.onelogin.com/security with a description. We follow responsible disclosure guidelines, and will work with you to quickly find a resolution.

## Getting Started
In order to use the toolkit you will need to install the gem (either manually or using Bundler), and require the library in your Ruby application:

Using `Gemfile`

```ruby
# latest stable
gem 'ruby-saml', '~> 1.0.0'

# or track master for bleeding-edge
gem 'ruby-saml', :github => 'onelogin/ruby-saml'
```

Using RubyGems

```sh
gem install ruby-saml
```

When requiring the gem, you can add the whole toolkit
```ruby
require 'onelogin/ruby-saml'
```

or just the required components individually:

```ruby
require 'onelogin/ruby-saml/authrequest'
```

### Installation on Ruby 1.8.7

This gem uses Nokogiri as a dependency, which dropped support for Ruby 1.8.x in Nokogiri 1.6. When installing this gem on Ruby 1.8.7, you will need to make sure a version of Nokogiri prior to 1.6 is installed or specified if it hasn't been already.

Using `Gemfile`

```ruby
gem 'nokogiri', '~> 1.5.10'
```

Using RubyGems

```sh
gem install nokogiri --version '~> 1.5.10'
````

### Configuring Logging

When troubleshooting SAML integration issues, you will find it extremely helpful to examine the
output of this gem's business logic. By default, log messages are emitted to RAILS_DEFAULT_LOGGER
when the gem is used in a Rails context, and to STDOUT when the gem is used outside of Rails.

To override the default behavior and control the destination of log messages, provide
a ruby Logger object to the gem's logging singleton:

```ruby
OneLogin::RubySaml::Logging.logger = Logger.new(File.open('/var/log/ruby-saml.log', 'w'))
```

## The Initialization Phase

This is the first request you will get from the identity provider. It will hit your application at a specific URL that you've announced as your SAML initialization point. The response to this initialization is a redirect back to the identity provider, which can look something like this (ignore the saml_settings method call for now):

```ruby
def init
  request = OneLogin::RubySaml::Authrequest.new
  redirect_to(request.create(saml_settings))
end
```

Once you've redirected back to the identity provider, it will ensure that the user has been authorized and redirect back to your application for final consumption. This can look something like this (the `authorize_success` and `authorize_failure` methods are specific to your application):

```ruby
def consume
  response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_settings)

  # We validate the SAML Response and check if the user already exists in the system
  if response.is_valid?
     # authorize_success, log the user
     session[:userid] = response.nameid
     session[:attributes] = response.attributes
  else
    authorize_failure  # This method shows an error message
  end
end
```

In the above there are a few assumptions, one being that `response.nameid` is an email address. This is all handled with how you specify the settings that are in play via the `saml_settings` method. That could be implemented along the lines of this:

```
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
response.settings = saml_settings
```

If the assertion of the SAMLResponse is not encrypted, you can initialize the Response without the `:settings` parameter and set it later.
If the SAMLResponse contains an encrypted assertion, you need to provide the settings in the
initialize method in order to obtain the decrypted assertion, using the service provider private key in order to decrypt.
If you don't know what expect, always use the former (set the settings on initialize).

```ruby
def saml_settings
  settings = OneLogin::RubySaml::Settings.new

  settings.assertion_consumer_service_url = "http://#{request.host}/saml/consume"
  settings.issuer                         = "http://#{request.host}/saml/metadata"
  settings.idp_entity_id                  = "https://app.onelogin.com/saml/metadata/#{OneLoginAppId}"
  settings.idp_sso_target_url             = "https://app.onelogin.com/trust/saml2/http-post/sso/#{OneLoginAppId}"
  settings.idp_slo_target_url             = "https://app.onelogin.com/trust/saml2/http-redirect/slo/#{OneLoginAppId}"
  settings.idp_cert_fingerprint           = OneLoginAppCertFingerPrint
  settings.idp_cert_fingerprint_algorithm = "http://www.w3.org/2000/09/xmldsig#sha1"
  settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

  # Optional for most SAML IdPs
  settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
  # or as an array
  settings.authn_context = [
    "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport",
    "urn:oasis:names:tc:SAML:2.0:ac:classes:Password"
  ]

  # Optional bindings (defaults to Redirect for logout POST for acs)
  settings.single_logout_service_binding      = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
  settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"

  settings
end
```

Some assertion validations can be skipped by passing parameters to `OneLogin::RubySaml::Response.new()`.  For example, you can skip the `Conditions`, `Recipient`, or the `SubjectConfirmation` validations by initializing the response with different options:

```ruby
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], {skip_conditions: true}) # skips conditions
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], {skip_subject_confirmation: true}) # skips subject confirmation
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], {skip_recipient_check: true}) # doens't skip subject confirmation, but skips the recipient check which is a sub check of the subject_confirmation check
```

All that's left is to wrap everything in a controller and reference it in the initialization and consumption URLs in OneLogin. A full controller example could look like this:

```ruby
# This controller expects you to use the URLs /saml/init and /saml/consume in your OneLogin application.
class SamlController < ApplicationController
  def init
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def consume
    response          = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
    response.settings = saml_settings

    # We validate the SAML Response and check if the user already exists in the system
    if response.is_valid?
       # authorize_success, log the user
       session[:userid] = response.nameid
       session[:attributes] = response.attributes
    else
      authorize_failure  # This method shows an error message
    end
  end

  private

  def saml_settings
    settings = OneLogin::RubySaml::Settings.new

    settings.assertion_consumer_service_url = "http://#{request.host}/saml/consume"
    settings.issuer                         = "http://#{request.host}/saml/metadata"
    settings.idp_sso_target_url             = "https://app.onelogin.com/saml/signon/#{OneLoginAppId}"
    settings.idp_cert_fingerprint           = OneLoginAppCertFingerPrint
    settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    # Optional for most SAML IdPs
    settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

    # Optional. Describe according to IdP specification (if supported) which attributes the SP desires to receive in SAMLResponse.
    settings.attributes_index = 5
    # Optional. Describe an attribute consuming service for support of additional attributes.
    settings.attribute_consuming_service.configure do
      service_name "Service"
      service_index 5
      add_attribute :name => "Name", :name_format => "Name Format", :friendly_name => "Friendly Name"
    end

    settings
  end
end
```


## Signature validation

On the ruby-saml toolkit there are different ways to validate the signature of the SAMLResponse:
- You can provide the IdP x509 public certificate at the 'idp_cert' setting.
- You can provide the IdP x509 public certificate in fingerprint format using the 'idp_cert_fingerprint' setting parameter and additionally the 'idp_cert_fingerprint_algorithm' parameter.

When validating the signature of redirect binding, the fingerprint is useless and the certficate of the IdP is required in order to execute the validation.
You can pass the option :relax_signature_validation to SloLogoutrequest and Logoutresponse if want to avoid signature validation if no certificate of the IdP is provided.

In some scenarios the IdP uses different certificates for signing/encryption, or is under key rollover phase and more than one certificate is published on IdP metadata.

In order to handle that the toolkit offers the 'idp_cert_multi' parameter.
When used, 'idp_cert' and 'idp_cert_fingerprint' values are ignored.

That 'idp_cert_multi' must be a Hash as follows:
{
  :signing => [],
  :encryption => []
}

And on 'signing' and 'encryption' arrays, add the different IdP x509 public certificates published on the IdP metadata.


## Metadata Based Configuration

The method above requires a little extra work to manually specify attributes about the IdP.  (And your SP application)  There's an easier method -- use a metadata exchange.  Metadata is just an XML file that defines the capabilities of both the IdP and the SP application.  It also contains the X.509 public
key certificates which add to the trusted relationship.  The IdP administrator can also configure custom settings for an SP based on the metadata.

Using ```idp_metadata_parser.parse_remote``` IdP metadata will be added to the settings without further ado.

```ruby
def saml_settings

  idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
  # Returns OneLogin::RubySaml::Settings prepopulated with idp metadata
  settings = idp_metadata_parser.parse_remote("https://example.com/auth/saml2/idp/metadata")

  settings.assertion_consumer_service_url = "http://#{request.host}/saml/consume"
  settings.issuer                         = "http://#{request.host}/saml/metadata"
  settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  # Optional for most SAML IdPs
  settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

  settings
end
```
The following attributes are set:
  * idp_entity_id
  * name_identifier_format
  * idp_sso_target_url
  * idp_slo_target_url
  * idp_attribute_names
  * idp_cert 
  * idp_cert_fingerprint 
  * idp_cert_multi

### Retrieve one Entity Descriptor when many exist in Metadata

If the Metadata contains several entities, the relevant Entity
Descriptor can be specified when retrieving the settings from the
IdpMetadataParser by its Entity Id value:

```ruby
  validate_cert = true
  settings =  idp_metadata_parser.parse_remote(
                "https://example.com/auth/saml2/idp/metadata",
                validate_cert,
                entity_id: "http//example.com/target/entity"
              )
```

### Parsing Metadata into an Hash

The `OneLogin::RubySaml::IdpMetadataParser` also provides the methods `#parse_to_hash` and `#parse_remote_to_hash`.
Those return an Hash instead of a `Settings` object, which may be useful for configuring
[omniauth-saml](https://github.com/omniauth/omniauth-saml), for instance.

## Retrieving Attributes

If you are using `saml:AttributeStatement` to transfer data like the username, you can access all the attributes through `response.attributes`. It contains all the `saml:AttributeStatement`s with its 'Name' as an indifferent key and one or more `saml:AttributeValue`s as values. The value returned depends on the value of the
`single_value_compatibility` (when activated, only the first value is returned)

```ruby
response          = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
response.settings = saml_settings

response.attributes[:username]
```

Imagine this `saml:AttributeStatement`

```xml
  <saml:AttributeStatement>
    <saml:Attribute Name="uid">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">demo</saml:AttributeValue>
    </saml:Attribute>
    <saml:Attribute Name="another_value">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">value1</saml:AttributeValue>
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">value2</saml:AttributeValue>
    </saml:Attribute>
    <saml:Attribute Name="role">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">role1</saml:AttributeValue>
    </saml:Attribute>
    <saml:Attribute Name="role">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">role2</saml:AttributeValue>
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">role3</saml:AttributeValue>
    </saml:Attribute>
    <saml:Attribute Name="attribute_with_nil_value">
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/>
    </saml:Attribute>
    <saml:Attribute Name="attribute_with_nils_and_empty_strings">
      <saml:AttributeValue/>
      <saml:AttributeValue>valuePresent</saml:AttributeValue>
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/>
      <saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="1"/>
    </saml:Attribute>
  </saml:AttributeStatement>
```

```ruby
pp(response.attributes)   # is an OneLogin::RubySaml::Attributes object
# => @attributes=
  {"uid"=>["demo"],
   "another_value"=>["value1", "value2"],
   "role"=>["role1", "role2", "role3"],
   "attribute_with_nil_value"=>[nil],
   "attribute_with_nils_and_empty_strings"=>["", "valuePresent", nil, nil]}>

# Active single_value_compatibility
OneLogin::RubySaml::Attributes.single_value_compatibility = true

pp(response.attributes[:uid])
# => "demo"

pp(response.attributes[:role])
# => "role1"

pp(response.attributes.single(:role))
# => "role1"

pp(response.attributes.multi(:role))
# => ["role1", "role2", "role3"]

pp(response.attributes[:attribute_with_nil_value])
# => nil

pp(response.attributes[:attribute_with_nils_and_empty_strings])
# => ""

pp(response.attributes[:not_exists])
# => nil

pp(response.attributes.single(:not_exists))
# => nil

pp(response.attributes.multi(:not_exists))
# => nil

# Deactive single_value_compatibility
OneLogin::RubySaml::Attributes.single_value_compatibility = false

pp(response.attributes[:uid])
# => ["demo"]

pp(response.attributes[:role])
# => ["role1", "role2", "role3"]

pp(response.attributes.single(:role))
# => "role1"

pp(response.attributes.multi(:role))
# => ["role1", "role2", "role3"]

pp(response.attributes[:attribute_with_nil_value])
# => [nil]

pp(response.attributes[:attribute_with_nils_and_empty_strings])
# => ["", "valuePresent", nil, nil]

pp(response.attributes[:not_exists])
# => nil

pp(response.attributes.single(:not_exists))
# => nil

pp(response.attributes.multi(:not_exists))
# => nil
```

The `saml:AuthnContextClassRef` of the AuthNRequest can be provided by `settings.authn_context`; possible values are described at [SAMLAuthnCxt]. The comparison method can be set using `settings.authn_context_comparison` parameter. Possible values include: 'exact', 'better', 'maximum' and 'minimum' (default value is 'exact').
To add a `saml:AuthnContextDeclRef`, define `settings.authn_context_decl_ref`.


## Signing

The Ruby Toolkit supports 2 different kinds of signature: Embeded and `GET` parameters

In order to be able to sign, define the private key and the public cert of the service provider:

```ruby
  settings.certificate = "CERTIFICATE TEXT WITH HEAD AND FOOT"
  settings.private_key = "PRIVATE KEY TEXT WITH HEAD AND FOOT"
```

The settings related to sign are stored in the `security` attribute of the settings:

```ruby
  settings.security[:authn_requests_signed]   = true     # Enable or not signature on AuthNRequest
  settings.security[:logout_requests_signed]  = true     # Enable or not signature on Logout Request
  settings.security[:logout_responses_signed] = true     # Enable or not signature on Logout Response
  settings.security[:want_assertions_signed]  = true     # Enable or not the requirement of signed assertion
  settings.security[:metadata_signed]         = true     # Enable or not signature on Metadata

  settings.security[:digest_method]    = XMLSecurity::Document::SHA1
  settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1

  # Embeded signature or HTTP GET parameter signature
  # Note that metadata signature is always embedded regardless of this value.
  settings.security[:embed_sign] = false
```

Notice that the RelayState parameter is used when creating the Signature on the HTTP-Redirect Binding.
Remember to provide it to the Signature builder if you are sending a `GET RelayState` parameter or the
signature validation process will fail at the Identity Provider.

The Service Provider will sign the request/responses with its private key.
The Identity Provider will validate the sign of the received request/responses with the public x500 cert of the
Service Provider.

Notice that this toolkit uses 'settings.certificate' and 'settings.private_key' for the sign and decrypt processes.

Enable/disable the soft mode with the `settings.soft` parameter. When set to `false`, saml validations errors will raise an exception.

## Decrypting

The Ruby Toolkit supports EncryptedAssertion.

In order to be able to decrypt a SAML Response that contains a EncryptedAssertion you need define the private key and the public cert of the service provider, then share this with the Identity Provider.

```ruby
  settings.certificate = "CERTIFICATE TEXT WITH HEAD AND FOOT"
  settings.private_key = "PRIVATE KEY TEXT WITH HEAD AND FOOT"
```

The Identity Provider will encrypt the Assertion with the public cert of the Service Provider.
The Service Provider will decrypt the EncryptedAssertion with its private key.

Notice that this toolkit uses 'settings.certificate' and 'settings.private_key' for the sign and decrypt processes.


## Key rollover

If you plan to update the SP x509cert and privateKey you can define the parameter 'certificate_new' at the settings and that new SP public certificate will be published on the SP metadata so Identity Providers can read them and get ready for rollover.


## Single Log Out

The Ruby Toolkit supports SP-initiated Single Logout and IdP-Initiated Single Logout.

Here is an example that we could add to our previous controller to generate and send a SAML Logout Request to the IdP:

```ruby
# Create a SP initiated SLO
def sp_logout_request
  # LogoutRequest accepts plain browser requests w/o paramters
  settings = saml_settings

  if settings.idp_slo_target_url.nil?
    logger.info "SLO IdP Endpoint not found in settings, executing then a normal logout'"
    delete_session
  else

    # Since we created a new SAML request, save the transaction_id
    # to compare it with the response we get back
    logout_request = OneLogin::RubySaml::Logoutrequest.new()
    session[:transaction_id] = logout_request.uuid
    logger.info "New SP SLO for userid '#{session[:userid]}' transactionid '#{session[:transaction_id]}'"

    if settings.name_identifier_value.nil?
      settings.name_identifier_value = session[:userid]
    end

    relayState =  url_for controller: 'saml', action: 'index'
    redirect_to(logout_request.create(settings, :RelayState => relayState))
  end
end
```

This method processes the SAML Logout Response sent by the IdP as the reply of the SAML Logout Request:

```ruby
# After sending an SP initiated LogoutRequest to the IdP, we need to accept
# the LogoutResponse, verify it, then actually delete our session.
def process_logout_response
  settings = Account.get_saml_settings

  if session.has_key? :transaction_id
    logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings, :matches_request_id => session[:transaction_id])
  else
    logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
  end

  logger.info "LogoutResponse is: #{logout_response.to_s}"

  # Validate the SAML Logout Response
  if not logout_response.validate
    logger.error "The SAML Logout Response is invalid"
  else
    # Actually log out this session
    logger.info "Delete session for '#{session[:userid]}'"
    delete_session
  end
end

# Delete a user's session.
def delete_session
  session[:userid] = nil
  session[:attributes] = nil
end
```

Here is an example that we could add to our previous controller to process a SAML Logout Request from the IdP and reply with a SAML Logout Response to the IdP:

```ruby
# Method to handle IdP initiated logouts
def idp_logout_request
  settings = Account.get_saml_settings
  logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest])
  if !logout_request.is_valid?
    logger.error "IdP initiated LogoutRequest was not valid!"
    render :inline => logger.error
  end
  logger.info "IdP initiated Logout for #{logout_request.name_id}"

  # Actually log out this session
  delete_session

  # Generate a response to the IdP.
  logout_request_id = logout_request.id
  logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(settings, logout_request_id, nil, :RelayState => params[:RelayState])
  redirect_to logout_response
end
```

All the mentioned methods could be handled in a unique view:

```ruby
# Trigger SP and IdP initiated Logout requests
def logout
  # If we're given a logout request, handle it in the IdP logout initiated method
  if params[:SAMLRequest]
    return idp_logout_request
  # We've been given a response back from the IdP, process it
  elsif params[:SAMLResponse]
    return process_logout_response
  # Initiate SLO (send Logout Request)
  else
    return sp_logout_request
  end
end
```



## Service Provider Metadata

To form a trusted pair relationship with the IdP, the SP (you) need to provide metadata XML
to the IdP for various good reasons.  (Caching, certificate lookups, relaying party permissions, etc)

The class `OneLogin::RubySaml::Metadata` takes care of this by reading the Settings and returning XML.  All you have to do is add a controller to return the data, then give this URL to the IdP administrator.

The metadata will be polled by the IdP every few minutes, so updating your settings should propagate
to the IdP settings.

```ruby
class SamlController < ApplicationController
  # ... the rest of your controller definitions ...
  def metadata
    settings = Account.get_saml_settings
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(settings), :content_type => "application/samlmetadata+xml"
  end
end
```


## Clock Drift

Server clocks tend to drift naturally. If during validation of the response you get the error "Current time is earlier than NotBefore condition", this may be due to clock differences between your system and that of the Identity Provider.

First, ensure that both systems synchronize their clocks, using for example the industry standard [Network Time Protocol (NTP)](http://en.wikipedia.org/wiki/Network_Time_Protocol).

Even then you may experience intermittent issues, as the clock of the Identity Provider may drift slightly ahead of your system clocks. To allow for a small amount of clock drift, you can initialize the response by passing in an option named `:allowed_clock_drift`. Its value must be given in a number (and/or fraction) of seconds. The value given is added to the current time at which the response is validated before it's tested against the `NotBefore` assertion. For example:

```ruby
response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :allowed_clock_drift => 1.second)
```

Make sure to keep the value as comfortably small as possible to keep security risks to a minimum.

## Attribute Service

To request attributes from the IdP the SP needs to provide an attribute service within it's metadata and reference the index in the assertion.

```ruby
settings = OneLogin::RubySaml::Settings.new

settings.attributes_index = 5
settings.attribute_consuming_service.configure do
  service_name "Service"
  service_index 5
  add_attribute :name => "Name", :name_format => "Name Format", :friendly_name => "Friendly Name"
  add_attribute :name => "Another Attribute", :name_format => "Name Format", :friendly_name => "Friendly Name", :attribute_value => "Attribute Value"
end
```

The `attribute_value` option additionally accepts an array of possible values.
