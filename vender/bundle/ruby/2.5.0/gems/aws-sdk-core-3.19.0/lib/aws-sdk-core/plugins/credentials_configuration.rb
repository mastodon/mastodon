module Aws
  # @api private
  module Plugins
    # @api private
    class CredentialsConfiguration < Seahorse::Client::Plugin

      option(:access_key_id, doc_type: String, docstring: '')

      option(:secret_access_key, doc_type: String, docstring: '')

      option(:session_token, doc_type: String, docstring: '')

      option(:profile,
        doc_default: 'default',
        doc_type: String,
        docstring: <<-DOCS)
Used when loading credentials from the shared credentials file
at HOME/.aws/credentials.  When not specified, 'default' is used.
        DOCS

      option(:credentials,
        required: true,
        doc_type: 'Aws::CredentialProvider',
        docstring: <<-DOCS
Your AWS credentials. This can be an instance of any one of the
following classes:

* `Aws::Credentials` - Used for configuring static, non-refreshing
  credentials.

* `Aws::InstanceProfileCredentials` - Used for loading credentials
  from an EC2 IMDS on an EC2 instance.

* `Aws::SharedCredentials` - Used for loading credentials from a
  shared file, such as `~/.aws/config`.

* `Aws::AssumeRoleCredentials` - Used when you need to assume a role.

When `:credentials` are not configured directly, the following
locations will be searched for credentials:

* `Aws.config[:credentials]`
* The `:access_key_id`, `:secret_access_key`, and `:session_token` options.
* ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']
* `~/.aws/credentials`
* `~/.aws/config`
* EC2 IMDS instance profile - When used by default, the timeouts are
  very aggressive. Construct and pass an instance of
  `Aws::InstanceProfileCredentails` to enable retries and extended
  timeouts.
        DOCS
      ) do |config|
        CredentialProviderChain.new(config).resolve
      end

      option(:instance_profile_credentials_retries, 0)

      option(:instance_profile_credentials_timeout, 1)

    end
  end
end
