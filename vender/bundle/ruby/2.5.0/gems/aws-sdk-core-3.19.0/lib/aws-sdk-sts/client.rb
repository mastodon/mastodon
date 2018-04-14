# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

require 'seahorse/client/plugins/content_length.rb'
require 'aws-sdk-core/plugins/credentials_configuration.rb'
require 'aws-sdk-core/plugins/logging.rb'
require 'aws-sdk-core/plugins/param_converter.rb'
require 'aws-sdk-core/plugins/param_validator.rb'
require 'aws-sdk-core/plugins/user_agent.rb'
require 'aws-sdk-core/plugins/helpful_socket_errors.rb'
require 'aws-sdk-core/plugins/retry_errors.rb'
require 'aws-sdk-core/plugins/global_configuration.rb'
require 'aws-sdk-core/plugins/regional_endpoint.rb'
require 'aws-sdk-core/plugins/response_paging.rb'
require 'aws-sdk-core/plugins/stub_responses.rb'
require 'aws-sdk-core/plugins/idempotency_token.rb'
require 'aws-sdk-core/plugins/jsonvalue_converter.rb'
require 'aws-sdk-core/plugins/signature_v4.rb'
require 'aws-sdk-core/plugins/protocols/query.rb'

Aws::Plugins::GlobalConfiguration.add_identifier(:sts)

module Aws::STS
  class Client < Seahorse::Client::Base

    include Aws::ClientStubs

    @identifier = :sts

    set_api(ClientApi::API)

    add_plugin(Seahorse::Client::Plugins::ContentLength)
    add_plugin(Aws::Plugins::CredentialsConfiguration)
    add_plugin(Aws::Plugins::Logging)
    add_plugin(Aws::Plugins::ParamConverter)
    add_plugin(Aws::Plugins::ParamValidator)
    add_plugin(Aws::Plugins::UserAgent)
    add_plugin(Aws::Plugins::HelpfulSocketErrors)
    add_plugin(Aws::Plugins::RetryErrors)
    add_plugin(Aws::Plugins::GlobalConfiguration)
    add_plugin(Aws::Plugins::RegionalEndpoint)
    add_plugin(Aws::Plugins::ResponsePaging)
    add_plugin(Aws::Plugins::StubResponses)
    add_plugin(Aws::Plugins::IdempotencyToken)
    add_plugin(Aws::Plugins::JsonvalueConverter)
    add_plugin(Aws::Plugins::SignatureV4)
    add_plugin(Aws::Plugins::Protocols::Query)

    # @option options [required, Aws::CredentialProvider] :credentials
    #   Your AWS credentials. This can be an instance of any one of the
    #   following classes:
    #
    #   * `Aws::Credentials` - Used for configuring static, non-refreshing
    #     credentials.
    #
    #   * `Aws::InstanceProfileCredentials` - Used for loading credentials
    #     from an EC2 IMDS on an EC2 instance.
    #
    #   * `Aws::SharedCredentials` - Used for loading credentials from a
    #     shared file, such as `~/.aws/config`.
    #
    #   * `Aws::AssumeRoleCredentials` - Used when you need to assume a role.
    #
    #   When `:credentials` are not configured directly, the following
    #   locations will be searched for credentials:
    #
    #   * `Aws.config[:credentials]`
    #   * The `:access_key_id`, `:secret_access_key`, and `:session_token` options.
    #   * ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']
    #   * `~/.aws/credentials`
    #   * `~/.aws/config`
    #   * EC2 IMDS instance profile - When used by default, the timeouts are
    #     very aggressive. Construct and pass an instance of
    #     `Aws::InstanceProfileCredentails` to enable retries and extended
    #     timeouts.
    #
    # @option options [required, String] :region
    #   The AWS region to connect to.  The configured `:region` is
    #   used to determine the service `:endpoint`. When not passed,
    #   a default `:region` is search for in the following locations:
    #
    #   * `Aws.config[:region]`
    #   * `ENV['AWS_REGION']`
    #   * `ENV['AMAZON_REGION']`
    #   * `ENV['AWS_DEFAULT_REGION']`
    #   * `~/.aws/credentials`
    #   * `~/.aws/config`
    #
    # @option options [String] :access_key_id
    #
    # @option options [Boolean] :convert_params (true)
    #   When `true`, an attempt is made to coerce request parameters into
    #   the required types.
    #
    # @option options [String] :endpoint
    #   The client endpoint is normally constructed from the `:region`
    #   option. You should only configure an `:endpoint` when connecting
    #   to test endpoints. This should be avalid HTTP(S) URI.
    #
    # @option options [Aws::Log::Formatter] :log_formatter (Aws::Log::Formatter.default)
    #   The log formatter.
    #
    # @option options [Symbol] :log_level (:info)
    #   The log level to send messages to the `:logger` at.
    #
    # @option options [Logger] :logger
    #   The Logger instance to send log messages to.  If this option
    #   is not set, logging will be disabled.
    #
    # @option options [String] :profile ("default")
    #   Used when loading credentials from the shared credentials file
    #   at HOME/.aws/credentials.  When not specified, 'default' is used.
    #
    # @option options [Integer] :retry_limit (3)
    #   The maximum number of times to retry failed requests.  Only
    #   ~ 500 level server errors and certain ~ 400 level client errors
    #   are retried.  Generally, these are throttling errors, data
    #   checksum errors, networking errors, timeout errors and auth
    #   errors from expired credentials.
    #
    # @option options [String] :secret_access_key
    #
    # @option options [String] :session_token
    #
    # @option options [Boolean] :stub_responses (false)
    #   Causes the client to return stubbed responses. By default
    #   fake responses are generated and returned. You can specify
    #   the response data to return or errors to raise by calling
    #   {ClientStubs#stub_responses}. See {ClientStubs} for more information.
    #
    #   ** Please note ** When response stubbing is enabled, no HTTP
    #   requests are made, and retries are disabled.
    #
    # @option options [Boolean] :validate_params (true)
    #   When `true`, request parameters are validated before
    #   sending the request.
    #
    def initialize(*args)
      super
    end

    # @!group API Operations

    # Returns a set of temporary security credentials (consisting of an
    # access key ID, a secret access key, and a security token) that you can
    # use to access AWS resources that you might not normally have access
    # to. Typically, you use `AssumeRole` for cross-account access or
    # federation. For a comparison of `AssumeRole` with the other APIs that
    # produce temporary credentials, see [Requesting Temporary Security
    # Credentials][1] and [Comparing the AWS STS APIs][2] in the *IAM User
    # Guide*.
    #
    # **Important:** You cannot call `AssumeRole` by using AWS root account
    # credentials; access is denied. You must use credentials for an IAM
    # user or an IAM role to call `AssumeRole`.
    #
    # For cross-account access, imagine that you own multiple accounts and
    # need to access resources in each account. You could create long-term
    # credentials in each account to access those resources. However,
    # managing all those credentials and remembering which one can access
    # which account can be time consuming. Instead, you can create one set
    # of long-term credentials in one account and then use temporary
    # security credentials to access all the other accounts by assuming
    # roles in those accounts. For more information about roles, see [IAM
    # Roles (Delegation and Federation)][3] in the *IAM User Guide*.
    #
    # For federation, you can, for example, grant single sign-on access to
    # the AWS Management Console. If you already have an identity and
    # authentication system in your corporate network, you don't have to
    # recreate user identities in AWS in order to grant those user
    # identities access to AWS. Instead, after a user has been
    # authenticated, you call `AssumeRole` (and specify the role with the
    # appropriate permissions) to get temporary security credentials for
    # that user. With those temporary security credentials, you construct a
    # sign-in URL that users can use to access the console. For more
    # information, see [Common Scenarios for Temporary Credentials][4] in
    # the *IAM User Guide*.
    #
    # By default, the temporary security credentials created by `AssumeRole`
    # last for one hour. However, you can use the optional `DurationSeconds`
    # parameter to specify the duration of your session. You can provide a
    # value from 900 seconds (15 minutes) up to the maximum session duration
    # setting for the role. This setting can have a value from 1 hour to 12
    # hours. To learn how to view the maximum value for your role, see [View
    # the Maximum Session Duration Setting for a Role][5] in the *IAM User
    # Guide*. The maximum session duration limit applies when you use the
    # `AssumeRole*` API operations or the `assume-role*` CLI operations but
    # does not apply when you use those operations to create a console URL.
    # For more information, see [Using IAM Roles][6] in the *IAM User
    # Guide*.
    #
    # The temporary security credentials created by `AssumeRole` can be used
    # to make API calls to any AWS service with the following exception: you
    # cannot call the STS service's `GetFederationToken` or
    # `GetSessionToken` APIs.
    #
    # Optionally, you can pass an IAM access policy to this operation. If
    # you choose not to pass a policy, the temporary security credentials
    # that are returned by the operation have the permissions that are
    # defined in the access policy of the role that is being assumed. If you
    # pass a policy to this operation, the temporary security credentials
    # that are returned by the operation have the permissions that are
    # allowed by both the access policy of the role that is being assumed,
    # <i> <b>and</b> </i> the policy that you pass. This gives you a way to
    # further restrict the permissions for the resulting temporary security
    # credentials. You cannot use the passed policy to grant permissions
    # that are in excess of those allowed by the access policy of the role
    # that is being assumed. For more information, see [Permissions for
    # AssumeRole, AssumeRoleWithSAML, and AssumeRoleWithWebIdentity][7] in
    # the *IAM User Guide*.
    #
    # To assume a role, your AWS account must be trusted by the role. The
    # trust relationship is defined in the role's trust policy when the
    # role is created. That trust policy states which accounts are allowed
    # to delegate access to this account's role.
    #
    # The user who wants to access the role must also have permissions
    # delegated from the role's administrator. If the user is in a
    # different account than the role, then the user's administrator must
    # attach a policy that allows the user to call AssumeRole on the ARN of
    # the role in the other account. If the user is in the same account as
    # the role, then you can either attach a policy to the user (identical
    # to the previous different account user), or you can add the user as a
    # principal directly in the role's trust policy. In this case, the
    # trust policy acts as the only resource-based policy in IAM, and users
    # in the same account as the role do not need explicit permission to
    # assume the role. For more information about trust policies and
    # resource-based policies, see [IAM Policies][8] in the *IAM User
    # Guide*.
    #
    # **Using MFA with AssumeRole**
    #
    # You can optionally include multi-factor authentication (MFA)
    # information when you call `AssumeRole`. This is useful for
    # cross-account scenarios in which you want to make sure that the user
    # who is assuming the role has been authenticated using an AWS MFA
    # device. In that scenario, the trust policy of the role being assumed
    # includes a condition that tests for MFA authentication; if the caller
    # does not include valid MFA information, the request to assume the role
    # is denied. The condition in a trust policy that tests for MFA
    # authentication might look like the following example.
    #
    # `"Condition": \{"Bool": \{"aws:MultiFactorAuthPresent": true\}\}`
    #
    # For more information, see [Configuring MFA-Protected API Access][9] in
    # the *IAM User Guide* guide.
    #
    # To use MFA with `AssumeRole`, you pass values for the `SerialNumber`
    # and `TokenCode` parameters. The `SerialNumber` value identifies the
    # user's hardware or virtual MFA device. The `TokenCode` is the
    # time-based one-time password (TOTP) that the MFA devices produces.
    #
    #
    #
    # [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html
    # [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html#stsapi_comparison
    # [3]: http://docs.aws.amazon.com/IAM/latest/UserGuide/roles-toplevel.html
    # [4]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html#sts-introduction
    # [5]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session
    # [6]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html
    # [7]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_assumerole.html
    # [8]: http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
    # [9]: http://docs.aws.amazon.com/IAM/latest/UserGuide/MFAProtectedAPI.html
    #
    # @option params [required, String] :role_arn
    #   The Amazon Resource Name (ARN) of the role to assume.
    #
    # @option params [required, String] :role_session_name
    #   An identifier for the assumed role session.
    #
    #   Use the role session name to uniquely identify a session when the same
    #   role is assumed by different principals or for different reasons. In
    #   cross-account scenarios, the role session name is visible to, and can
    #   be logged by the account that owns the role. The role session name is
    #   also used in the ARN of the assumed role principal. This means that
    #   subsequent cross-account API requests using the temporary security
    #   credentials will expose the role session name to the external account
    #   in their CloudTrail logs.
    #
    #   The regex used to validate this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@-
    #
    # @option params [String] :policy
    #   An IAM policy in JSON format.
    #
    #   This parameter is optional. If you pass a policy, the temporary
    #   security credentials that are returned by the operation have the
    #   permissions that are allowed by both (the intersection of) the access
    #   policy of the role that is being assumed, *and* the policy that you
    #   pass. This gives you a way to further restrict the permissions for the
    #   resulting temporary security credentials. You cannot use the passed
    #   policy to grant permissions that are in excess of those allowed by the
    #   access policy of the role that is being assumed. For more information,
    #   see [Permissions for AssumeRole, AssumeRoleWithSAML, and
    #   AssumeRoleWithWebIdentity][1] in the *IAM User Guide*.
    #
    #   The format for this parameter, as described by its regex pattern, is a
    #   string of characters up to 2048 characters in length. The characters
    #   can be any ASCII character from the space character to the end of the
    #   valid character list (\\u0020-\\u00FF). It can also include the tab
    #   (\\u0009), linefeed (\\u000A), and carriage return (\\u000D)
    #   characters.
    #
    #   <note markdown="1"> The policy plain text must be 2048 bytes or shorter. However, an
    #   internal conversion compresses it into a packed binary format with a
    #   separate limit. The PackedPolicySize response element indicates by
    #   percentage how close to the upper size limit the policy is, with 100%
    #   equaling the maximum allowed size.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_assumerole.html
    #
    # @option params [Integer] :duration_seconds
    #   The duration, in seconds, of the role session. The value can range
    #   from 900 seconds (15 minutes) up to the maximum session duration
    #   setting for the role. This setting can have a value from 1 hour to 12
    #   hours. If you specify a value higher than this setting, the operation
    #   fails. For example, if you specify a session duration of 12 hours, but
    #   your administrator set the maximum session duration to 6 hours, your
    #   operation fails. To learn how to view the maximum value for your role,
    #   see [View the Maximum Session Duration Setting for a Role][1] in the
    #   *IAM User Guide*.
    #
    #   By default, the value is set to 3600 seconds.
    #
    #   <note markdown="1"> The `DurationSeconds` parameter is separate from the duration of a
    #   console session that you might request using the returned credentials.
    #   The request to the federation endpoint for a console sign-in token
    #   takes a `SessionDuration` parameter that specifies the maximum length
    #   of the console session. For more information, see [Creating a URL that
    #   Enables Federated Users to Access the AWS Management Console][2] in
    #   the *IAM User Guide*.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session
    #   [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html
    #
    # @option params [String] :external_id
    #   A unique identifier that is used by third parties when assuming roles
    #   in their customers' accounts. For each role that the third party can
    #   assume, they should instruct their customers to ensure the role's
    #   trust policy checks for the external ID that the third party
    #   generated. Each time the third party assumes the role, they should
    #   pass the customer's external ID. The external ID is useful in order
    #   to help third parties bind a role to the customer who created it. For
    #   more information about the external ID, see [How to Use an External ID
    #   When Granting Access to Your AWS Resources to a Third Party][1] in the
    #   *IAM User Guide*.
    #
    #   The regex used to validated this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@:/-
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html
    #
    # @option params [String] :serial_number
    #   The identification number of the MFA device that is associated with
    #   the user who is making the `AssumeRole` call. Specify this value if
    #   the trust policy of the role being assumed includes a condition that
    #   requires MFA authentication. The value is either the serial number for
    #   a hardware device (such as `GAHT12345678`) or an Amazon Resource Name
    #   (ARN) for a virtual device (such as
    #   `arn:aws:iam::123456789012:mfa/user`).
    #
    #   The regex used to validate this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@-
    #
    # @option params [String] :token_code
    #   The value provided by the MFA device, if the trust policy of the role
    #   being assumed requires MFA (that is, if the policy includes a
    #   condition that tests for MFA). If the role being assumed requires MFA
    #   and if the `TokenCode` value is missing or expired, the `AssumeRole`
    #   call returns an "access denied" error.
    #
    #   The format for this parameter, as described by its regex pattern, is a
    #   sequence of six numeric digits.
    #
    # @return [Types::AssumeRoleResponse] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::AssumeRoleResponse#credentials #credentials} => Types::Credentials
    #   * {Types::AssumeRoleResponse#assumed_role_user #assumed_role_user} => Types::AssumedRoleUser
    #   * {Types::AssumeRoleResponse#packed_policy_size #packed_policy_size} => Integer
    #
    #
    # @example Example: To assume a role
    #
    #   resp = client.assume_role({
    #     duration_seconds: 3600, 
    #     external_id: "123ABC", 
    #     policy: "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"Stmt1\",\"Effect\":\"Allow\",\"Action\":\"s3:*\",\"Resource\":\"*\"}]}", 
    #     role_arn: "arn:aws:iam::123456789012:role/demo", 
    #     role_session_name: "Bob", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     assumed_role_user: {
    #       arn: "arn:aws:sts::123456789012:assumed-role/demo/Bob", 
    #       assumed_role_id: "ARO123EXAMPLE123:Bob", 
    #     }, 
    #     credentials: {
    #       access_key_id: "AKIAIOSFODNN7EXAMPLE", 
    #       expiration: Time.parse("2011-07-15T23:28:33.359Z"), 
    #       secret_access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY", 
    #       session_token: "AQoDYXdzEPT//////////wEXAMPLEtc764bNrC9SAPBSM22wDOk4x4HIZ8j4FZTwdQWLWsKWHGBuFqwAeMicRXmxfpSPfIeoIYRqTflfKD8YUuwthAx7mSEI/qkPpKPi/kMcGdQrmGdeehM4IC1NtBmUpp2wUE8phUZampKsburEDy0KPkyQDYwT7WZ0wq5VSXDvp75YU9HFvlRd8Tx6q6fE8YQcHNVXAkiY9q6d+xo0rKwT38xVqr7ZD0u0iPPkUL64lIZbqBAz+scqKmlzm8FDrypNC9Yjc8fPOLn9FX9KSYvKTr4rvx3iSIlTJabIQwj2ICCR/oLxBA==", 
    #     }, 
    #     packed_policy_size: 6, 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.assume_role({
    #     role_arn: "arnType", # required
    #     role_session_name: "roleSessionNameType", # required
    #     policy: "sessionPolicyDocumentType",
    #     duration_seconds: 1,
    #     external_id: "externalIdType",
    #     serial_number: "serialNumberType",
    #     token_code: "tokenCodeType",
    #   })
    #
    # @example Response structure
    #
    #   resp.credentials.access_key_id #=> String
    #   resp.credentials.secret_access_key #=> String
    #   resp.credentials.session_token #=> String
    #   resp.credentials.expiration #=> Time
    #   resp.assumed_role_user.assumed_role_id #=> String
    #   resp.assumed_role_user.arn #=> String
    #   resp.packed_policy_size #=> Integer
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumeRole AWS API Documentation
    #
    # @overload assume_role(params = {})
    # @param [Hash] params ({})
    def assume_role(params = {}, options = {})
      req = build_request(:assume_role, params)
      req.send_request(options)
    end

    # Returns a set of temporary security credentials for users who have
    # been authenticated via a SAML authentication response. This operation
    # provides a mechanism for tying an enterprise identity store or
    # directory to role-based AWS access without user-specific credentials
    # or configuration. For a comparison of `AssumeRoleWithSAML` with the
    # other APIs that produce temporary credentials, see [Requesting
    # Temporary Security Credentials][1] and [Comparing the AWS STS APIs][2]
    # in the *IAM User Guide*.
    #
    # The temporary security credentials returned by this operation consist
    # of an access key ID, a secret access key, and a security token.
    # Applications can use these temporary security credentials to sign
    # calls to AWS services.
    #
    # By default, the temporary security credentials created by
    # `AssumeRoleWithSAML` last for one hour. However, you can use the
    # optional `DurationSeconds` parameter to specify the duration of your
    # session. Your role session lasts for the duration that you specify, or
    # until the time specified in the SAML authentication response's
    # `SessionNotOnOrAfter` value, whichever is shorter. You can provide a
    # `DurationSeconds` value from 900 seconds (15 minutes) up to the
    # maximum session duration setting for the role. This setting can have a
    # value from 1 hour to 12 hours. To learn how to view the maximum value
    # for your role, see [View the Maximum Session Duration Setting for a
    # Role][3] in the *IAM User Guide*. The maximum session duration limit
    # applies when you use the `AssumeRole*` API operations or the
    # `assume-role*` CLI operations but does not apply when you use those
    # operations to create a console URL. For more information, see [Using
    # IAM Roles][4] in the *IAM User Guide*.
    #
    # The temporary security credentials created by `AssumeRoleWithSAML` can
    # be used to make API calls to any AWS service with the following
    # exception: you cannot call the STS service's `GetFederationToken` or
    # `GetSessionToken` APIs.
    #
    # Optionally, you can pass an IAM access policy to this operation. If
    # you choose not to pass a policy, the temporary security credentials
    # that are returned by the operation have the permissions that are
    # defined in the access policy of the role that is being assumed. If you
    # pass a policy to this operation, the temporary security credentials
    # that are returned by the operation have the permissions that are
    # allowed by the intersection of both the access policy of the role that
    # is being assumed, <i> <b>and</b> </i> the policy that you pass. This
    # means that both policies must grant the permission for the action to
    # be allowed. This gives you a way to further restrict the permissions
    # for the resulting temporary security credentials. You cannot use the
    # passed policy to grant permissions that are in excess of those allowed
    # by the access policy of the role that is being assumed. For more
    # information, see [Permissions for AssumeRole, AssumeRoleWithSAML, and
    # AssumeRoleWithWebIdentity][5] in the *IAM User Guide*.
    #
    # Before your application can call `AssumeRoleWithSAML`, you must
    # configure your SAML identity provider (IdP) to issue the claims
    # required by AWS. Additionally, you must use AWS Identity and Access
    # Management (IAM) to create a SAML provider entity in your AWS account
    # that represents your identity provider, and create an IAM role that
    # specifies this SAML provider in its trust policy.
    #
    # Calling `AssumeRoleWithSAML` does not require the use of AWS security
    # credentials. The identity of the caller is validated by using keys in
    # the metadata document that is uploaded for the SAML provider entity
    # for your identity provider.
    #
    # Calling `AssumeRoleWithSAML` can result in an entry in your AWS
    # CloudTrail logs. The entry includes the value in the `NameID` element
    # of the SAML assertion. We recommend that you use a NameIDType that is
    # not associated with any personally identifiable information (PII). For
    # example, you could instead use the Persistent Identifier
    # (`urn:oasis:names:tc:SAML:2.0:nameid-format:persistent`).
    #
    # For more information, see the following resources:
    #
    # * [About SAML 2.0-based Federation][6] in the *IAM User Guide*.
    #
    # * [Creating SAML Identity Providers][7] in the *IAM User Guide*.
    #
    # * [Configuring a Relying Party and Claims][8] in the *IAM User Guide*.
    #
    # * [Creating a Role for SAML 2.0 Federation][9] in the *IAM User
    #   Guide*.
    #
    #
    #
    # [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html
    # [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html#stsapi_comparison
    # [3]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session
    # [4]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html
    # [5]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_assumerole.html
    # [6]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_saml.html
    # [7]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_saml.html
    # [8]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_saml_relying-party.html
    # [9]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_saml.html
    #
    # @option params [required, String] :role_arn
    #   The Amazon Resource Name (ARN) of the role that the caller is
    #   assuming.
    #
    # @option params [required, String] :principal_arn
    #   The Amazon Resource Name (ARN) of the SAML provider in IAM that
    #   describes the IdP.
    #
    # @option params [required, String] :saml_assertion
    #   The base-64 encoded SAML authentication response provided by the IdP.
    #
    #   For more information, see [Configuring a Relying Party and Adding
    #   Claims][1] in the *Using IAM* guide.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/create-role-saml-IdP-tasks.html
    #
    # @option params [String] :policy
    #   An IAM policy in JSON format.
    #
    #   The policy parameter is optional. If you pass a policy, the temporary
    #   security credentials that are returned by the operation have the
    #   permissions that are allowed by both the access policy of the role
    #   that is being assumed, <i> <b>and</b> </i> the policy that you pass.
    #   This gives you a way to further restrict the permissions for the
    #   resulting temporary security credentials. You cannot use the passed
    #   policy to grant permissions that are in excess of those allowed by the
    #   access policy of the role that is being assumed. For more information,
    #   [Permissions for AssumeRole, AssumeRoleWithSAML, and
    #   AssumeRoleWithWebIdentity][1] in the *IAM User Guide*.
    #
    #   The format for this parameter, as described by its regex pattern, is a
    #   string of characters up to 2048 characters in length. The characters
    #   can be any ASCII character from the space character to the end of the
    #   valid character list (\\u0020-\\u00FF). It can also include the tab
    #   (\\u0009), linefeed (\\u000A), and carriage return (\\u000D)
    #   characters.
    #
    #   <note markdown="1"> The policy plain text must be 2048 bytes or shorter. However, an
    #   internal conversion compresses it into a packed binary format with a
    #   separate limit. The PackedPolicySize response element indicates by
    #   percentage how close to the upper size limit the policy is, with 100%
    #   equaling the maximum allowed size.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_assumerole.html
    #
    # @option params [Integer] :duration_seconds
    #   The duration, in seconds, of the role session. Your role session lasts
    #   for the duration that you specify for the `DurationSeconds` parameter,
    #   or until the time specified in the SAML authentication response's
    #   `SessionNotOnOrAfter` value, whichever is shorter. You can provide a
    #   `DurationSeconds` value from 900 seconds (15 minutes) up to the
    #   maximum session duration setting for the role. This setting can have a
    #   value from 1 hour to 12 hours. If you specify a value higher than this
    #   setting, the operation fails. For example, if you specify a session
    #   duration of 12 hours, but your administrator set the maximum session
    #   duration to 6 hours, your operation fails. To learn how to view the
    #   maximum value for your role, see [View the Maximum Session Duration
    #   Setting for a Role][1] in the *IAM User Guide*.
    #
    #   By default, the value is set to 3600 seconds.
    #
    #   <note markdown="1"> The `DurationSeconds` parameter is separate from the duration of a
    #   console session that you might request using the returned credentials.
    #   The request to the federation endpoint for a console sign-in token
    #   takes a `SessionDuration` parameter that specifies the maximum length
    #   of the console session. For more information, see [Creating a URL that
    #   Enables Federated Users to Access the AWS Management Console][2] in
    #   the *IAM User Guide*.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session
    #   [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html
    #
    # @return [Types::AssumeRoleWithSAMLResponse] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::AssumeRoleWithSAMLResponse#credentials #credentials} => Types::Credentials
    #   * {Types::AssumeRoleWithSAMLResponse#assumed_role_user #assumed_role_user} => Types::AssumedRoleUser
    #   * {Types::AssumeRoleWithSAMLResponse#packed_policy_size #packed_policy_size} => Integer
    #   * {Types::AssumeRoleWithSAMLResponse#subject #subject} => String
    #   * {Types::AssumeRoleWithSAMLResponse#subject_type #subject_type} => String
    #   * {Types::AssumeRoleWithSAMLResponse#issuer #issuer} => String
    #   * {Types::AssumeRoleWithSAMLResponse#audience #audience} => String
    #   * {Types::AssumeRoleWithSAMLResponse#name_qualifier #name_qualifier} => String
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.assume_role_with_saml({
    #     role_arn: "arnType", # required
    #     principal_arn: "arnType", # required
    #     saml_assertion: "SAMLAssertionType", # required
    #     policy: "sessionPolicyDocumentType",
    #     duration_seconds: 1,
    #   })
    #
    # @example Response structure
    #
    #   resp.credentials.access_key_id #=> String
    #   resp.credentials.secret_access_key #=> String
    #   resp.credentials.session_token #=> String
    #   resp.credentials.expiration #=> Time
    #   resp.assumed_role_user.assumed_role_id #=> String
    #   resp.assumed_role_user.arn #=> String
    #   resp.packed_policy_size #=> Integer
    #   resp.subject #=> String
    #   resp.subject_type #=> String
    #   resp.issuer #=> String
    #   resp.audience #=> String
    #   resp.name_qualifier #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumeRoleWithSAML AWS API Documentation
    #
    # @overload assume_role_with_saml(params = {})
    # @param [Hash] params ({})
    def assume_role_with_saml(params = {}, options = {})
      req = build_request(:assume_role_with_saml, params)
      req.send_request(options)
    end

    # Returns a set of temporary security credentials for users who have
    # been authenticated in a mobile or web application with a web identity
    # provider, such as Amazon Cognito, Login with Amazon, Facebook, Google,
    # or any OpenID Connect-compatible identity provider.
    #
    # <note markdown="1"> For mobile applications, we recommend that you use Amazon Cognito. You
    # can use Amazon Cognito with the [AWS SDK for iOS][1] and the [AWS SDK
    # for Android][2] to uniquely identify a user and supply the user with a
    # consistent identity throughout the lifetime of an application.
    #
    #  To learn more about Amazon Cognito, see [Amazon Cognito Overview][3]
    # in the *AWS SDK for Android Developer Guide* guide and [Amazon Cognito
    # Overview][4] in the *AWS SDK for iOS Developer Guide*.
    #
    #  </note>
    #
    # Calling `AssumeRoleWithWebIdentity` does not require the use of AWS
    # security credentials. Therefore, you can distribute an application
    # (for example, on mobile devices) that requests temporary security
    # credentials without including long-term AWS credentials in the
    # application, and without deploying server-based proxy services that
    # use long-term AWS credentials. Instead, the identity of the caller is
    # validated by using a token from the web identity provider. For a
    # comparison of `AssumeRoleWithWebIdentity` with the other APIs that
    # produce temporary credentials, see [Requesting Temporary Security
    # Credentials][5] and [Comparing the AWS STS APIs][6] in the *IAM User
    # Guide*.
    #
    # The temporary security credentials returned by this API consist of an
    # access key ID, a secret access key, and a security token. Applications
    # can use these temporary security credentials to sign calls to AWS
    # service APIs.
    #
    # By default, the temporary security credentials created by
    # `AssumeRoleWithWebIdentity` last for one hour. However, you can use
    # the optional `DurationSeconds` parameter to specify the duration of
    # your session. You can provide a value from 900 seconds (15 minutes) up
    # to the maximum session duration setting for the role. This setting can
    # have a value from 1 hour to 12 hours. To learn how to view the maximum
    # value for your role, see [View the Maximum Session Duration Setting
    # for a Role][7] in the *IAM User Guide*. The maximum session duration
    # limit applies when you use the `AssumeRole*` API operations or the
    # `assume-role*` CLI operations but does not apply when you use those
    # operations to create a console URL. For more information, see [Using
    # IAM Roles][8] in the *IAM User Guide*.
    #
    # The temporary security credentials created by
    # `AssumeRoleWithWebIdentity` can be used to make API calls to any AWS
    # service with the following exception: you cannot call the STS
    # service's `GetFederationToken` or `GetSessionToken` APIs.
    #
    # Optionally, you can pass an IAM access policy to this operation. If
    # you choose not to pass a policy, the temporary security credentials
    # that are returned by the operation have the permissions that are
    # defined in the access policy of the role that is being assumed. If you
    # pass a policy to this operation, the temporary security credentials
    # that are returned by the operation have the permissions that are
    # allowed by both the access policy of the role that is being assumed,
    # <i> <b>and</b> </i> the policy that you pass. This gives you a way to
    # further restrict the permissions for the resulting temporary security
    # credentials. You cannot use the passed policy to grant permissions
    # that are in excess of those allowed by the access policy of the role
    # that is being assumed. For more information, see [Permissions for
    # AssumeRole, AssumeRoleWithSAML, and AssumeRoleWithWebIdentity][9] in
    # the *IAM User Guide*.
    #
    # Before your application can call `AssumeRoleWithWebIdentity`, you must
    # have an identity token from a supported identity provider and create a
    # role that the application can assume. The role that your application
    # assumes must trust the identity provider that is associated with the
    # identity token. In other words, the identity provider must be
    # specified in the role's trust policy.
    #
    # Calling `AssumeRoleWithWebIdentity` can result in an entry in your AWS
    # CloudTrail logs. The entry includes the [Subject][10] of the provided
    # Web Identity Token. We recommend that you avoid using any personally
    # identifiable information (PII) in this field. For example, you could
    # instead use a GUID or a pairwise identifier, as [suggested in the OIDC
    # specification][11].
    #
    # For more information about how to use web identity federation and the
    # `AssumeRoleWithWebIdentity` API, see the following resources:
    #
    # * [Using Web Identity Federation APIs for Mobile Apps][12] and
    #   [Federation Through a Web-based Identity Provider][13].
    #
    # * [ Web Identity Federation Playground][14]. This interactive website
    #   lets you walk through the process of authenticating via Login with
    #   Amazon, Facebook, or Google, getting temporary security credentials,
    #   and then using those credentials to make a request to AWS.
    #
    # * [AWS SDK for iOS][1] and [AWS SDK for Android][2]. These toolkits
    #   contain sample apps that show how to invoke the identity providers,
    #   and then how to use the information from these providers to get and
    #   use temporary security credentials.
    #
    # * [Web Identity Federation with Mobile Applications][15]. This article
    #   discusses web identity federation and shows an example of how to use
    #   web identity federation to get access to content in Amazon S3.
    #
    #
    #
    # [1]: http://aws.amazon.com/sdkforios/
    # [2]: http://aws.amazon.com/sdkforandroid/
    # [3]: http://docs.aws.amazon.com/mobile/sdkforandroid/developerguide/cognito-auth.html#d0e840
    # [4]: http://docs.aws.amazon.com/mobile/sdkforios/developerguide/cognito-auth.html#d0e664
    # [5]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html
    # [6]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html#stsapi_comparison
    # [7]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session
    # [8]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html
    # [9]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_assumerole.html
    # [10]: http://openid.net/specs/openid-connect-core-1_0.html#Claims
    # [11]: http://openid.net/specs/openid-connect-core-1_0.html#SubjectIDTypes
    # [12]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_oidc_manual.html
    # [13]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html#api_assumerolewithwebidentity
    # [14]: https://web-identity-federation-playground.s3.amazonaws.com/index.html
    # [15]: http://aws.amazon.com/articles/web-identity-federation-with-mobile-applications
    #
    # @option params [required, String] :role_arn
    #   The Amazon Resource Name (ARN) of the role that the caller is
    #   assuming.
    #
    # @option params [required, String] :role_session_name
    #   An identifier for the assumed role session. Typically, you pass the
    #   name or identifier that is associated with the user who is using your
    #   application. That way, the temporary security credentials that your
    #   application will use are associated with that user. This session name
    #   is included as part of the ARN and assumed role ID in the
    #   `AssumedRoleUser` response element.
    #
    #   The regex used to validate this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@-
    #
    # @option params [required, String] :web_identity_token
    #   The OAuth 2.0 access token or OpenID Connect ID token that is provided
    #   by the identity provider. Your application must get this token by
    #   authenticating the user who is using your application with a web
    #   identity provider before the application makes an
    #   `AssumeRoleWithWebIdentity` call.
    #
    # @option params [String] :provider_id
    #   The fully qualified host component of the domain name of the identity
    #   provider.
    #
    #   Specify this value only for OAuth 2.0 access tokens. Currently
    #   `www.amazon.com` and `graph.facebook.com` are the only supported
    #   identity providers for OAuth 2.0 access tokens. Do not include URL
    #   schemes and port numbers.
    #
    #   Do not specify this value for OpenID Connect ID tokens.
    #
    # @option params [String] :policy
    #   An IAM policy in JSON format.
    #
    #   The policy parameter is optional. If you pass a policy, the temporary
    #   security credentials that are returned by the operation have the
    #   permissions that are allowed by both the access policy of the role
    #   that is being assumed, <i> <b>and</b> </i> the policy that you pass.
    #   This gives you a way to further restrict the permissions for the
    #   resulting temporary security credentials. You cannot use the passed
    #   policy to grant permissions that are in excess of those allowed by the
    #   access policy of the role that is being assumed. For more information,
    #   see [Permissions for AssumeRoleWithWebIdentity][1] in the *IAM User
    #   Guide*.
    #
    #   The format for this parameter, as described by its regex pattern, is a
    #   string of characters up to 2048 characters in length. The characters
    #   can be any ASCII character from the space character to the end of the
    #   valid character list (\\u0020-\\u00FF). It can also include the tab
    #   (\\u0009), linefeed (\\u000A), and carriage return (\\u000D)
    #   characters.
    #
    #   <note markdown="1"> The policy plain text must be 2048 bytes or shorter. However, an
    #   internal conversion compresses it into a packed binary format with a
    #   separate limit. The PackedPolicySize response element indicates by
    #   percentage how close to the upper size limit the policy is, with 100%
    #   equaling the maximum allowed size.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_assumerole.html
    #
    # @option params [Integer] :duration_seconds
    #   The duration, in seconds, of the role session. The value can range
    #   from 900 seconds (15 minutes) up to the maximum session duration
    #   setting for the role. This setting can have a value from 1 hour to 12
    #   hours. If you specify a value higher than this setting, the operation
    #   fails. For example, if you specify a session duration of 12 hours, but
    #   your administrator set the maximum session duration to 6 hours, your
    #   operation fails. To learn how to view the maximum value for your role,
    #   see [View the Maximum Session Duration Setting for a Role][1] in the
    #   *IAM User Guide*.
    #
    #   By default, the value is set to 3600 seconds.
    #
    #   <note markdown="1"> The `DurationSeconds` parameter is separate from the duration of a
    #   console session that you might request using the returned credentials.
    #   The request to the federation endpoint for a console sign-in token
    #   takes a `SessionDuration` parameter that specifies the maximum length
    #   of the console session. For more information, see [Creating a URL that
    #   Enables Federated Users to Access the AWS Management Console][2] in
    #   the *IAM User Guide*.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session
    #   [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html
    #
    # @return [Types::AssumeRoleWithWebIdentityResponse] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::AssumeRoleWithWebIdentityResponse#credentials #credentials} => Types::Credentials
    #   * {Types::AssumeRoleWithWebIdentityResponse#subject_from_web_identity_token #subject_from_web_identity_token} => String
    #   * {Types::AssumeRoleWithWebIdentityResponse#assumed_role_user #assumed_role_user} => Types::AssumedRoleUser
    #   * {Types::AssumeRoleWithWebIdentityResponse#packed_policy_size #packed_policy_size} => Integer
    #   * {Types::AssumeRoleWithWebIdentityResponse#provider #provider} => String
    #   * {Types::AssumeRoleWithWebIdentityResponse#audience #audience} => String
    #
    #
    # @example Example: To assume a role as an OpenID Connect-federated user
    #
    #   resp = client.assume_role_with_web_identity({
    #     duration_seconds: 3600, 
    #     provider_id: "www.amazon.com", 
    #     role_arn: "arn:aws:iam::123456789012:role/FederatedWebIdentityRole", 
    #     role_session_name: "app1", 
    #     web_identity_token: "Atza%7CIQEBLjAsAhRFiXuWpUXuRvQ9PZL3GMFcYevydwIUFAHZwXZXXXXXXXXJnrulxKDHwy87oGKPznh0D6bEQZTSCzyoCtL_8S07pLpr0zMbn6w1lfVZKNTBdDansFBmtGnIsIapjI6xKR02Yc_2bQ8LZbUXSGm6Ry6_BG7PrtLZtj_dfCTj92xNGed-CrKqjG7nPBjNIL016GGvuS5gSvPRUxWES3VYfm1wl7WTI7jn-Pcb6M-buCgHhFOzTQxod27L9CqnOLio7N3gZAGpsp6n1-AJBOCJckcyXe2c6uD0srOJeZlKUm2eTDVMf8IehDVI0r1QOnTV6KzzAI3OY87Vd_cVMQ", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     assumed_role_user: {
    #       arn: "arn:aws:sts::123456789012:assumed-role/FederatedWebIdentityRole/app1", 
    #       assumed_role_id: "AROACLKWSDQRAOEXAMPLE:app1", 
    #     }, 
    #     audience: "client.5498841531868486423.1548@apps.example.com", 
    #     credentials: {
    #       access_key_id: "AKIAIOSFODNN7EXAMPLE", 
    #       expiration: Time.parse("2014-10-24T23:00:23Z"), 
    #       secret_access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY", 
    #       session_token: "AQoDYXdzEE0a8ANXXXXXXXXNO1ewxE5TijQyp+IEXAMPLE", 
    #     }, 
    #     packed_policy_size: 123, 
    #     provider: "www.amazon.com", 
    #     subject_from_web_identity_token: "amzn1.account.AF6RHO7KZU5XRVQJGXK6HEXAMPLE", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.assume_role_with_web_identity({
    #     role_arn: "arnType", # required
    #     role_session_name: "roleSessionNameType", # required
    #     web_identity_token: "clientTokenType", # required
    #     provider_id: "urlType",
    #     policy: "sessionPolicyDocumentType",
    #     duration_seconds: 1,
    #   })
    #
    # @example Response structure
    #
    #   resp.credentials.access_key_id #=> String
    #   resp.credentials.secret_access_key #=> String
    #   resp.credentials.session_token #=> String
    #   resp.credentials.expiration #=> Time
    #   resp.subject_from_web_identity_token #=> String
    #   resp.assumed_role_user.assumed_role_id #=> String
    #   resp.assumed_role_user.arn #=> String
    #   resp.packed_policy_size #=> Integer
    #   resp.provider #=> String
    #   resp.audience #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumeRoleWithWebIdentity AWS API Documentation
    #
    # @overload assume_role_with_web_identity(params = {})
    # @param [Hash] params ({})
    def assume_role_with_web_identity(params = {}, options = {})
      req = build_request(:assume_role_with_web_identity, params)
      req.send_request(options)
    end

    # Decodes additional information about the authorization status of a
    # request from an encoded message returned in response to an AWS
    # request.
    #
    # For example, if a user is not authorized to perform an action that he
    # or she has requested, the request returns a
    # `Client.UnauthorizedOperation` response (an HTTP 403 response). Some
    # AWS actions additionally return an encoded message that can provide
    # details about this authorization failure.
    #
    # <note markdown="1"> Only certain AWS actions return an encoded authorization message. The
    # documentation for an individual action indicates whether that action
    # returns an encoded message in addition to returning an HTTP code.
    #
    #  </note>
    #
    # The message is encoded because the details of the authorization status
    # can constitute privileged information that the user who requested the
    # action should not see. To decode an authorization status message, a
    # user must be granted permissions via an IAM policy to request the
    # `DecodeAuthorizationMessage` (`sts:DecodeAuthorizationMessage`)
    # action.
    #
    # The decoded message includes the following type of information:
    #
    # * Whether the request was denied due to an explicit deny or due to the
    #   absence of an explicit allow. For more information, see [Determining
    #   Whether a Request is Allowed or Denied][1] in the *IAM User Guide*.
    #
    # * The principal who made the request.
    #
    # * The requested action.
    #
    # * The requested resource.
    #
    # * The values of condition keys in the context of the user's request.
    #
    #
    #
    # [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html#policy-eval-denyallow
    #
    # @option params [required, String] :encoded_message
    #   The encoded message that was returned with the response.
    #
    # @return [Types::DecodeAuthorizationMessageResponse] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::DecodeAuthorizationMessageResponse#decoded_message #decoded_message} => String
    #
    #
    # @example Example: To decode information about an authorization status of a request
    #
    #   resp = client.decode_authorization_message({
    #     encoded_message: "<encoded-message>", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     decoded_message: "{\"allowed\": \"false\",\"explicitDeny\": \"false\",\"matchedStatements\": \"\",\"failures\": \"\",\"context\": {\"principal\": {\"id\": \"AIDACKCEVSQ6C2EXAMPLE\",\"name\": \"Bob\",\"arn\": \"arn:aws:iam::123456789012:user/Bob\"},\"action\": \"ec2:StopInstances\",\"resource\": \"arn:aws:ec2:us-east-1:123456789012:instance/i-dd01c9bd\",\"conditions\": [{\"item\": {\"key\": \"ec2:Tenancy\",\"values\": [\"default\"]},{\"item\": {\"key\": \"ec2:ResourceTag/elasticbeanstalk:environment-name\",\"values\": [\"Default-Environment\"]}},(Additional items ...)]}}", 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.decode_authorization_message({
    #     encoded_message: "encodedMessageType", # required
    #   })
    #
    # @example Response structure
    #
    #   resp.decoded_message #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/DecodeAuthorizationMessage AWS API Documentation
    #
    # @overload decode_authorization_message(params = {})
    # @param [Hash] params ({})
    def decode_authorization_message(params = {}, options = {})
      req = build_request(:decode_authorization_message, params)
      req.send_request(options)
    end

    # Returns details about the IAM identity whose credentials are used to
    # call the API.
    #
    # @return [Types::GetCallerIdentityResponse] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetCallerIdentityResponse#user_id #user_id} => String
    #   * {Types::GetCallerIdentityResponse#account #account} => String
    #   * {Types::GetCallerIdentityResponse#arn #arn} => String
    #
    #
    # @example Example: To get details about a calling IAM user
    #
    #   # This example shows a request and response made with the credentials for a user named Alice in the AWS account
    #   # 123456789012.
    #
    #   resp = client.get_caller_identity({
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     account: "123456789012", 
    #     arn: "arn:aws:iam::123456789012:user/Alice", 
    #     user_id: "AKIAI44QH8DHBEXAMPLE", 
    #   }
    #
    # @example Example: To get details about a calling user federated with AssumeRole
    #
    #   # This example shows a request and response made with temporary credentials created by AssumeRole. The name of the assumed
    #   # role is my-role-name, and the RoleSessionName is set to my-role-session-name.
    #
    #   resp = client.get_caller_identity({
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     account: "123456789012", 
    #     arn: "arn:aws:sts::123456789012:assumed-role/my-role-name/my-role-session-name", 
    #     user_id: "AKIAI44QH8DHBEXAMPLE:my-role-session-name", 
    #   }
    #
    # @example Example: To get details about a calling user federated with GetFederationToken
    #
    #   # This example shows a request and response made with temporary credentials created by using GetFederationToken. The Name
    #   # parameter is set to my-federated-user-name.
    #
    #   resp = client.get_caller_identity({
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     account: "123456789012", 
    #     arn: "arn:aws:sts::123456789012:federated-user/my-federated-user-name", 
    #     user_id: "123456789012:my-federated-user-name", 
    #   }
    #
    # @example Response structure
    #
    #   resp.user_id #=> String
    #   resp.account #=> String
    #   resp.arn #=> String
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/GetCallerIdentity AWS API Documentation
    #
    # @overload get_caller_identity(params = {})
    # @param [Hash] params ({})
    def get_caller_identity(params = {}, options = {})
      req = build_request(:get_caller_identity, params)
      req.send_request(options)
    end

    # Returns a set of temporary security credentials (consisting of an
    # access key ID, a secret access key, and a security token) for a
    # federated user. A typical use is in a proxy application that gets
    # temporary security credentials on behalf of distributed applications
    # inside a corporate network. Because you must call the
    # `GetFederationToken` action using the long-term security credentials
    # of an IAM user, this call is appropriate in contexts where those
    # credentials can be safely stored, usually in a server-based
    # application. For a comparison of `GetFederationToken` with the other
    # APIs that produce temporary credentials, see [Requesting Temporary
    # Security Credentials][1] and [Comparing the AWS STS APIs][2] in the
    # *IAM User Guide*.
    #
    # <note markdown="1"> If you are creating a mobile-based or browser-based app that can
    # authenticate users using a web identity provider like Login with
    # Amazon, Facebook, Google, or an OpenID Connect-compatible identity
    # provider, we recommend that you use [Amazon Cognito][3] or
    # `AssumeRoleWithWebIdentity`. For more information, see [Federation
    # Through a Web-based Identity Provider][4].
    #
    #  </note>
    #
    # The `GetFederationToken` action must be called by using the long-term
    # AWS security credentials of an IAM user. You can also call
    # `GetFederationToken` using the security credentials of an AWS root
    # account, but we do not recommended it. Instead, we recommend that you
    # create an IAM user for the purpose of the proxy application and then
    # attach a policy to the IAM user that limits federated users to only
    # the actions and resources that they need access to. For more
    # information, see [IAM Best Practices][5] in the *IAM User Guide*.
    #
    # The temporary security credentials that are obtained by using the
    # long-term credentials of an IAM user are valid for the specified
    # duration, from 900 seconds (15 minutes) up to a maximium of 129600
    # seconds (36 hours). The default is 43200 seconds (12 hours). Temporary
    # credentials that are obtained by using AWS root account credentials
    # have a maximum duration of 3600 seconds (1 hour).
    #
    # The temporary security credentials created by `GetFederationToken` can
    # be used to make API calls to any AWS service with the following
    # exceptions:
    #
    # * You cannot use these credentials to call any IAM APIs.
    #
    # * You cannot call any STS APIs except `GetCallerIdentity`.
    #
    # **Permissions**
    #
    # The permissions for the temporary security credentials returned by
    # `GetFederationToken` are determined by a combination of the following:
    #
    # * The policy or policies that are attached to the IAM user whose
    #   credentials are used to call `GetFederationToken`.
    #
    # * The policy that is passed as a parameter in the call.
    #
    # The passed policy is attached to the temporary security credentials
    # that result from the `GetFederationToken` API call--that is, to the
    # *federated user*. When the federated user makes an AWS request, AWS
    # evaluates the policy attached to the federated user in combination
    # with the policy or policies attached to the IAM user whose credentials
    # were used to call `GetFederationToken`. AWS allows the federated
    # user's request only when both the federated user <i> <b>and</b> </i>
    # the IAM user are explicitly allowed to perform the requested action.
    # The passed policy cannot grant more permissions than those that are
    # defined in the IAM user policy.
    #
    # A typical use case is that the permissions of the IAM user whose
    # credentials are used to call `GetFederationToken` are designed to
    # allow access to all the actions and resources that any federated user
    # will need. Then, for individual users, you pass a policy to the
    # operation that scopes down the permissions to a level that's
    # appropriate to that individual user, using a policy that allows only a
    # subset of permissions that are granted to the IAM user.
    #
    # If you do not pass a policy, the resulting temporary security
    # credentials have no effective permissions. The only exception is when
    # the temporary security credentials are used to access a resource that
    # has a resource-based policy that specifically allows the federated
    # user to access the resource.
    #
    # For more information about how permissions work, see [Permissions for
    # GetFederationToken][6]. For information about using
    # `GetFederationToken` to create temporary security credentials, see
    # [GetFederationToken—Federation Through a Custom Identity Broker][7].
    #
    #
    #
    # [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html
    # [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html#stsapi_comparison
    # [3]: http://aws.amazon.com/cognito/
    # [4]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html#api_assumerolewithwebidentity
    # [5]: http://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
    # [6]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_getfederationtoken.html
    # [7]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html#api_getfederationtoken
    #
    # @option params [required, String] :name
    #   The name of the federated user. The name is used as an identifier for
    #   the temporary security credentials (such as `Bob`). For example, you
    #   can reference the federated user name in a resource-based policy, such
    #   as in an Amazon S3 bucket policy.
    #
    #   The regex used to validate this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@-
    #
    # @option params [String] :policy
    #   An IAM policy in JSON format that is passed with the
    #   `GetFederationToken` call and evaluated along with the policy or
    #   policies that are attached to the IAM user whose credentials are used
    #   to call `GetFederationToken`. The passed policy is used to scope down
    #   the permissions that are available to the IAM user, by allowing only a
    #   subset of the permissions that are granted to the IAM user. The passed
    #   policy cannot grant more permissions than those granted to the IAM
    #   user. The final permissions for the federated user are the most
    #   restrictive set based on the intersection of the passed policy and the
    #   IAM user policy.
    #
    #   If you do not pass a policy, the resulting temporary security
    #   credentials have no effective permissions. The only exception is when
    #   the temporary security credentials are used to access a resource that
    #   has a resource-based policy that specifically allows the federated
    #   user to access the resource.
    #
    #   The format for this parameter, as described by its regex pattern, is a
    #   string of characters up to 2048 characters in length. The characters
    #   can be any ASCII character from the space character to the end of the
    #   valid character list (\\u0020-\\u00FF). It can also include the tab
    #   (\\u0009), linefeed (\\u000A), and carriage return (\\u000D)
    #   characters.
    #
    #   <note markdown="1"> The policy plain text must be 2048 bytes or shorter. However, an
    #   internal conversion compresses it into a packed binary format with a
    #   separate limit. The PackedPolicySize response element indicates by
    #   percentage how close to the upper size limit the policy is, with 100%
    #   equaling the maximum allowed size.
    #
    #    </note>
    #
    #   For more information about how permissions work, see [Permissions for
    #   GetFederationToken][1].
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_getfederationtoken.html
    #
    # @option params [Integer] :duration_seconds
    #   The duration, in seconds, that the session should last. Acceptable
    #   durations for federation sessions range from 900 seconds (15 minutes)
    #   to 129600 seconds (36 hours), with 43200 seconds (12 hours) as the
    #   default. Sessions obtained using AWS account (root) credentials are
    #   restricted to a maximum of 3600 seconds (one hour). If the specified
    #   duration is longer than one hour, the session obtained by using AWS
    #   account (root) credentials defaults to one hour.
    #
    # @return [Types::GetFederationTokenResponse] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetFederationTokenResponse#credentials #credentials} => Types::Credentials
    #   * {Types::GetFederationTokenResponse#federated_user #federated_user} => Types::FederatedUser
    #   * {Types::GetFederationTokenResponse#packed_policy_size #packed_policy_size} => Integer
    #
    #
    # @example Example: To get temporary credentials for a role by using GetFederationToken
    #
    #   resp = client.get_federation_token({
    #     duration_seconds: 3600, 
    #     name: "Bob", 
    #     policy: "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"Stmt1\",\"Effect\":\"Allow\",\"Action\":\"s3:*\",\"Resource\":\"*\"}]}", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     credentials: {
    #       access_key_id: "AKIAIOSFODNN7EXAMPLE", 
    #       expiration: Time.parse("2011-07-15T23:28:33.359Z"), 
    #       secret_access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY", 
    #       session_token: "AQoDYXdzEPT//////////wEXAMPLEtc764bNrC9SAPBSM22wDOk4x4HIZ8j4FZTwdQWLWsKWHGBuFqwAeMicRXmxfpSPfIeoIYRqTflfKD8YUuwthAx7mSEI/qkPpKPi/kMcGdQrmGdeehM4IC1NtBmUpp2wUE8phUZampKsburEDy0KPkyQDYwT7WZ0wq5VSXDvp75YU9HFvlRd8Tx6q6fE8YQcHNVXAkiY9q6d+xo0rKwT38xVqr7ZD0u0iPPkUL64lIZbqBAz+scqKmlzm8FDrypNC9Yjc8fPOLn9FX9KSYvKTr4rvx3iSIlTJabIQwj2ICCR/oLxBA==", 
    #     }, 
    #     federated_user: {
    #       arn: "arn:aws:sts::123456789012:federated-user/Bob", 
    #       federated_user_id: "123456789012:Bob", 
    #     }, 
    #     packed_policy_size: 6, 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_federation_token({
    #     name: "userNameType", # required
    #     policy: "sessionPolicyDocumentType",
    #     duration_seconds: 1,
    #   })
    #
    # @example Response structure
    #
    #   resp.credentials.access_key_id #=> String
    #   resp.credentials.secret_access_key #=> String
    #   resp.credentials.session_token #=> String
    #   resp.credentials.expiration #=> Time
    #   resp.federated_user.federated_user_id #=> String
    #   resp.federated_user.arn #=> String
    #   resp.packed_policy_size #=> Integer
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/GetFederationToken AWS API Documentation
    #
    # @overload get_federation_token(params = {})
    # @param [Hash] params ({})
    def get_federation_token(params = {}, options = {})
      req = build_request(:get_federation_token, params)
      req.send_request(options)
    end

    # Returns a set of temporary credentials for an AWS account or IAM user.
    # The credentials consist of an access key ID, a secret access key, and
    # a security token. Typically, you use `GetSessionToken` if you want to
    # use MFA to protect programmatic calls to specific AWS APIs like Amazon
    # EC2 `StopInstances`. MFA-enabled IAM users would need to call
    # `GetSessionToken` and submit an MFA code that is associated with their
    # MFA device. Using the temporary security credentials that are returned
    # from the call, IAM users can then make programmatic calls to APIs that
    # require MFA authentication. If you do not supply a correct MFA code,
    # then the API returns an access denied error. For a comparison of
    # `GetSessionToken` with the other APIs that produce temporary
    # credentials, see [Requesting Temporary Security Credentials][1] and
    # [Comparing the AWS STS APIs][2] in the *IAM User Guide*.
    #
    # The `GetSessionToken` action must be called by using the long-term AWS
    # security credentials of the AWS account or an IAM user. Credentials
    # that are created by IAM users are valid for the duration that you
    # specify, from 900 seconds (15 minutes) up to a maximum of 129600
    # seconds (36 hours), with a default of 43200 seconds (12 hours);
    # credentials that are created by using account credentials can range
    # from 900 seconds (15 minutes) up to a maximum of 3600 seconds (1
    # hour), with a default of 1 hour.
    #
    # The temporary security credentials created by `GetSessionToken` can be
    # used to make API calls to any AWS service with the following
    # exceptions:
    #
    # * You cannot call any IAM APIs unless MFA authentication information
    #   is included in the request.
    #
    # * You cannot call any STS API *except* `AssumeRole` or
    #   `GetCallerIdentity`.
    #
    # <note markdown="1"> We recommend that you do not call `GetSessionToken` with root account
    # credentials. Instead, follow our [best practices][3] by creating one
    # or more IAM users, giving them the necessary permissions, and using
    # IAM users for everyday interaction with AWS.
    #
    #  </note>
    #
    # The permissions associated with the temporary security credentials
    # returned by `GetSessionToken` are based on the permissions associated
    # with account or IAM user whose credentials are used to call the
    # action. If `GetSessionToken` is called using root account credentials,
    # the temporary credentials have root account permissions. Similarly, if
    # `GetSessionToken` is called using the credentials of an IAM user, the
    # temporary credentials have the same permissions as the IAM user.
    #
    # For more information about using `GetSessionToken` to create temporary
    # credentials, go to [Temporary Credentials for Users in Untrusted
    # Environments][4] in the *IAM User Guide*.
    #
    #
    #
    # [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html
    # [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html#stsapi_comparison
    # [3]: http://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#create-iam-users
    # [4]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html#api_getsessiontoken
    #
    # @option params [Integer] :duration_seconds
    #   The duration, in seconds, that the credentials should remain valid.
    #   Acceptable durations for IAM user sessions range from 900 seconds (15
    #   minutes) to 129600 seconds (36 hours), with 43200 seconds (12 hours)
    #   as the default. Sessions for AWS account owners are restricted to a
    #   maximum of 3600 seconds (one hour). If the duration is longer than one
    #   hour, the session for AWS account owners defaults to one hour.
    #
    # @option params [String] :serial_number
    #   The identification number of the MFA device that is associated with
    #   the IAM user who is making the `GetSessionToken` call. Specify this
    #   value if the IAM user has a policy that requires MFA authentication.
    #   The value is either the serial number for a hardware device (such as
    #   `GAHT12345678`) or an Amazon Resource Name (ARN) for a virtual device
    #   (such as `arn:aws:iam::123456789012:mfa/user`). You can find the
    #   device for an IAM user by going to the AWS Management Console and
    #   viewing the user's security credentials.
    #
    #   The regex used to validated this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@:/-
    #
    # @option params [String] :token_code
    #   The value provided by the MFA device, if MFA is required. If any
    #   policy requires the IAM user to submit an MFA code, specify this
    #   value. If MFA authentication is required, and the user does not
    #   provide a code when requesting a set of temporary security
    #   credentials, the user will receive an "access denied" response when
    #   requesting resources that require MFA authentication.
    #
    #   The format for this parameter, as described by its regex pattern, is a
    #   sequence of six numeric digits.
    #
    # @return [Types::GetSessionTokenResponse] Returns a {Seahorse::Client::Response response} object which responds to the following methods:
    #
    #   * {Types::GetSessionTokenResponse#credentials #credentials} => Types::Credentials
    #
    #
    # @example Example: To get temporary credentials for an IAM user or an AWS account
    #
    #   resp = client.get_session_token({
    #     duration_seconds: 3600, 
    #     serial_number: "YourMFASerialNumber", 
    #     token_code: "123456", 
    #   })
    #
    #   resp.to_h outputs the following:
    #   {
    #     credentials: {
    #       access_key_id: "AKIAIOSFODNN7EXAMPLE", 
    #       expiration: Time.parse("2011-07-11T19:55:29.611Z"), 
    #       secret_access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY", 
    #       session_token: "AQoEXAMPLEH4aoAH0gNCAPyJxz4BlCFFxWNE1OPTgk5TthT+FvwqnKwRcOIfrRh3c/LTo6UDdyJwOOvEVPvLXCrrrUtdnniCEXAMPLE/IvU1dYUg2RVAJBanLiHb4IgRmpRV3zrkuWJOgQs8IZZaIv2BXIa2R4OlgkBN9bkUDNCJiBeb/AXlzBBko7b15fjrBs2+cTQtpZ3CYWFXG8C5zqx37wnOE49mRl/+OtkIKGO7fAE", 
    #     }, 
    #   }
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_session_token({
    #     duration_seconds: 1,
    #     serial_number: "serialNumberType",
    #     token_code: "tokenCodeType",
    #   })
    #
    # @example Response structure
    #
    #   resp.credentials.access_key_id #=> String
    #   resp.credentials.secret_access_key #=> String
    #   resp.credentials.session_token #=> String
    #   resp.credentials.expiration #=> Time
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/GetSessionToken AWS API Documentation
    #
    # @overload get_session_token(params = {})
    # @param [Hash] params ({})
    def get_session_token(params = {}, options = {})
      req = build_request(:get_session_token, params)
      req.send_request(options)
    end

    # @!endgroup

    # @param params ({})
    # @api private
    def build_request(operation_name, params = {})
      handlers = @handlers.for(operation_name)
      context = Seahorse::Client::RequestContext.new(
        operation_name: operation_name,
        operation: config.api.operation(operation_name),
        client: self,
        params: params,
        config: config)
      context[:gem_name] = 'aws-sdk-core'
      context[:gem_version] = '3.19.0'
      Seahorse::Client::Request.new(handlers, context)
    end

    # @api private
    # @deprecated
    def waiter_names
      []
    end

    class << self

      # @api private
      attr_reader :identifier

      # @api private
      def errors_module
        Errors
      end

    end
  end
end
