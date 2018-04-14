module Aws
  # @api private
  module Plugins
    # @api private
    # Used for APIGateway generated SDKs credentials config
    class APIGCredentialsConfiguration < Seahorse::Client::Plugin

      option(:access_key_id, doc_type: String, docstring: '')

      option(:secret_access_key, doc_type: String, docstring: '')

      option(:session_token, doc_type: String, docstring: '')

      option(:profile, doc_type: String, docstring: '')

      option(:credentials,
        required: false,
        doc_type: 'Aws::CredentialProvider',
        docstring: <<-DOCS
AWS Credentials options is only required when your API uses 
[AWS Signature Version 4](http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html),
more AWS Credentials Configuration Options are available [here](https://github.com/aws/aws-sdk-ruby#configuration).
        DOCS
      ) do |config|
        CredentialProviderChain.new(config).resolve
      end

      option(:instance_profile_credentials_retries, 0)

      option(:instance_profile_credentials_timeout, 1)

    end
  end
end
