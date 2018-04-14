# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

module Aws::STS
  module Types

    # @note When making an API call, you may pass AssumeRoleRequest
    #   data as a hash:
    #
    #       {
    #         role_arn: "arnType", # required
    #         role_session_name: "roleSessionNameType", # required
    #         policy: "sessionPolicyDocumentType",
    #         duration_seconds: 1,
    #         external_id: "externalIdType",
    #         serial_number: "serialNumberType",
    #         token_code: "tokenCodeType",
    #       }
    #
    # @!attribute [rw] role_arn
    #   The Amazon Resource Name (ARN) of the role to assume.
    #   @return [String]
    #
    # @!attribute [rw] role_session_name
    #   An identifier for the assumed role session.
    #
    #   Use the role session name to uniquely identify a session when the
    #   same role is assumed by different principals or for different
    #   reasons. In cross-account scenarios, the role session name is
    #   visible to, and can be logged by the account that owns the role. The
    #   role session name is also used in the ARN of the assumed role
    #   principal. This means that subsequent cross-account API requests
    #   using the temporary security credentials will expose the role
    #   session name to the external account in their CloudTrail logs.
    #
    #   The regex used to validate this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@-
    #   @return [String]
    #
    # @!attribute [rw] policy
    #   An IAM policy in JSON format.
    #
    #   This parameter is optional. If you pass a policy, the temporary
    #   security credentials that are returned by the operation have the
    #   permissions that are allowed by both (the intersection of) the
    #   access policy of the role that is being assumed, *and* the policy
    #   that you pass. This gives you a way to further restrict the
    #   permissions for the resulting temporary security credentials. You
    #   cannot use the passed policy to grant permissions that are in excess
    #   of those allowed by the access policy of the role that is being
    #   assumed. For more information, see [Permissions for AssumeRole,
    #   AssumeRoleWithSAML, and AssumeRoleWithWebIdentity][1] in the *IAM
    #   User Guide*.
    #
    #   The format for this parameter, as described by its regex pattern, is
    #   a string of characters up to 2048 characters in length. The
    #   characters can be any ASCII character from the space character to
    #   the end of the valid character list (\\u0020-\\u00FF). It can also
    #   include the tab (\\u0009), linefeed (\\u000A), and carriage return
    #   (\\u000D) characters.
    #
    #   <note markdown="1"> The policy plain text must be 2048 bytes or shorter. However, an
    #   internal conversion compresses it into a packed binary format with a
    #   separate limit. The PackedPolicySize response element indicates by
    #   percentage how close to the upper size limit the policy is, with
    #   100% equaling the maximum allowed size.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_assumerole.html
    #   @return [String]
    #
    # @!attribute [rw] duration_seconds
    #   The duration, in seconds, of the role session. The value can range
    #   from 900 seconds (15 minutes) up to the maximum session duration
    #   setting for the role. This setting can have a value from 1 hour to
    #   12 hours. If you specify a value higher than this setting, the
    #   operation fails. For example, if you specify a session duration of
    #   12 hours, but your administrator set the maximum session duration to
    #   6 hours, your operation fails. To learn how to view the maximum
    #   value for your role, see [View the Maximum Session Duration Setting
    #   for a Role][1] in the *IAM User Guide*.
    #
    #   By default, the value is set to 3600 seconds.
    #
    #   <note markdown="1"> The `DurationSeconds` parameter is separate from the duration of a
    #   console session that you might request using the returned
    #   credentials. The request to the federation endpoint for a console
    #   sign-in token takes a `SessionDuration` parameter that specifies the
    #   maximum length of the console session. For more information, see
    #   [Creating a URL that Enables Federated Users to Access the AWS
    #   Management Console][2] in the *IAM User Guide*.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session
    #   [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html
    #   @return [Integer]
    #
    # @!attribute [rw] external_id
    #   A unique identifier that is used by third parties when assuming
    #   roles in their customers' accounts. For each role that the third
    #   party can assume, they should instruct their customers to ensure the
    #   role's trust policy checks for the external ID that the third party
    #   generated. Each time the third party assumes the role, they should
    #   pass the customer's external ID. The external ID is useful in order
    #   to help third parties bind a role to the customer who created it.
    #   For more information about the external ID, see [How to Use an
    #   External ID When Granting Access to Your AWS Resources to a Third
    #   Party][1] in the *IAM User Guide*.
    #
    #   The regex used to validated this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@:/-
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html
    #   @return [String]
    #
    # @!attribute [rw] serial_number
    #   The identification number of the MFA device that is associated with
    #   the user who is making the `AssumeRole` call. Specify this value if
    #   the trust policy of the role being assumed includes a condition that
    #   requires MFA authentication. The value is either the serial number
    #   for a hardware device (such as `GAHT12345678`) or an Amazon Resource
    #   Name (ARN) for a virtual device (such as
    #   `arn:aws:iam::123456789012:mfa/user`).
    #
    #   The regex used to validate this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@-
    #   @return [String]
    #
    # @!attribute [rw] token_code
    #   The value provided by the MFA device, if the trust policy of the
    #   role being assumed requires MFA (that is, if the policy includes a
    #   condition that tests for MFA). If the role being assumed requires
    #   MFA and if the `TokenCode` value is missing or expired, the
    #   `AssumeRole` call returns an "access denied" error.
    #
    #   The format for this parameter, as described by its regex pattern, is
    #   a sequence of six numeric digits.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumeRoleRequest AWS API Documentation
    #
    class AssumeRoleRequest < Struct.new(
      :role_arn,
      :role_session_name,
      :policy,
      :duration_seconds,
      :external_id,
      :serial_number,
      :token_code)
      include Aws::Structure
    end

    # Contains the response to a successful AssumeRole request, including
    # temporary AWS credentials that can be used to make AWS requests.
    #
    # @!attribute [rw] credentials
    #   The temporary security credentials, which include an access key ID,
    #   a secret access key, and a security (or session) token.
    #
    #   **Note:** The size of the security token that STS APIs return is not
    #   fixed. We strongly recommend that you make no assumptions about the
    #   maximum size. As of this writing, the typical size is less than 4096
    #   bytes, but that can vary. Also, future updates to AWS might require
    #   larger sizes.
    #   @return [Types::Credentials]
    #
    # @!attribute [rw] assumed_role_user
    #   The Amazon Resource Name (ARN) and the assumed role ID, which are
    #   identifiers that you can use to refer to the resulting temporary
    #   security credentials. For example, you can reference these
    #   credentials as a principal in a resource-based policy by using the
    #   ARN or assumed role ID. The ARN and ID include the `RoleSessionName`
    #   that you specified when you called `AssumeRole`.
    #   @return [Types::AssumedRoleUser]
    #
    # @!attribute [rw] packed_policy_size
    #   A percentage value that indicates the size of the policy in packed
    #   form. The service rejects any policy with a packed size greater than
    #   100 percent, which means the policy exceeded the allowed space.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumeRoleResponse AWS API Documentation
    #
    class AssumeRoleResponse < Struct.new(
      :credentials,
      :assumed_role_user,
      :packed_policy_size)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AssumeRoleWithSAMLRequest
    #   data as a hash:
    #
    #       {
    #         role_arn: "arnType", # required
    #         principal_arn: "arnType", # required
    #         saml_assertion: "SAMLAssertionType", # required
    #         policy: "sessionPolicyDocumentType",
    #         duration_seconds: 1,
    #       }
    #
    # @!attribute [rw] role_arn
    #   The Amazon Resource Name (ARN) of the role that the caller is
    #   assuming.
    #   @return [String]
    #
    # @!attribute [rw] principal_arn
    #   The Amazon Resource Name (ARN) of the SAML provider in IAM that
    #   describes the IdP.
    #   @return [String]
    #
    # @!attribute [rw] saml_assertion
    #   The base-64 encoded SAML authentication response provided by the
    #   IdP.
    #
    #   For more information, see [Configuring a Relying Party and Adding
    #   Claims][1] in the *Using IAM* guide.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/create-role-saml-IdP-tasks.html
    #   @return [String]
    #
    # @!attribute [rw] policy
    #   An IAM policy in JSON format.
    #
    #   The policy parameter is optional. If you pass a policy, the
    #   temporary security credentials that are returned by the operation
    #   have the permissions that are allowed by both the access policy of
    #   the role that is being assumed, <i> <b>and</b> </i> the policy that
    #   you pass. This gives you a way to further restrict the permissions
    #   for the resulting temporary security credentials. You cannot use the
    #   passed policy to grant permissions that are in excess of those
    #   allowed by the access policy of the role that is being assumed. For
    #   more information, [Permissions for AssumeRole, AssumeRoleWithSAML,
    #   and AssumeRoleWithWebIdentity][1] in the *IAM User Guide*.
    #
    #   The format for this parameter, as described by its regex pattern, is
    #   a string of characters up to 2048 characters in length. The
    #   characters can be any ASCII character from the space character to
    #   the end of the valid character list (\\u0020-\\u00FF). It can also
    #   include the tab (\\u0009), linefeed (\\u000A), and carriage return
    #   (\\u000D) characters.
    #
    #   <note markdown="1"> The policy plain text must be 2048 bytes or shorter. However, an
    #   internal conversion compresses it into a packed binary format with a
    #   separate limit. The PackedPolicySize response element indicates by
    #   percentage how close to the upper size limit the policy is, with
    #   100% equaling the maximum allowed size.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_assumerole.html
    #   @return [String]
    #
    # @!attribute [rw] duration_seconds
    #   The duration, in seconds, of the role session. Your role session
    #   lasts for the duration that you specify for the `DurationSeconds`
    #   parameter, or until the time specified in the SAML authentication
    #   response's `SessionNotOnOrAfter` value, whichever is shorter. You
    #   can provide a `DurationSeconds` value from 900 seconds (15 minutes)
    #   up to the maximum session duration setting for the role. This
    #   setting can have a value from 1 hour to 12 hours. If you specify a
    #   value higher than this setting, the operation fails. For example, if
    #   you specify a session duration of 12 hours, but your administrator
    #   set the maximum session duration to 6 hours, your operation fails.
    #   To learn how to view the maximum value for your role, see [View the
    #   Maximum Session Duration Setting for a Role][1] in the *IAM User
    #   Guide*.
    #
    #   By default, the value is set to 3600 seconds.
    #
    #   <note markdown="1"> The `DurationSeconds` parameter is separate from the duration of a
    #   console session that you might request using the returned
    #   credentials. The request to the federation endpoint for a console
    #   sign-in token takes a `SessionDuration` parameter that specifies the
    #   maximum length of the console session. For more information, see
    #   [Creating a URL that Enables Federated Users to Access the AWS
    #   Management Console][2] in the *IAM User Guide*.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session
    #   [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumeRoleWithSAMLRequest AWS API Documentation
    #
    class AssumeRoleWithSAMLRequest < Struct.new(
      :role_arn,
      :principal_arn,
      :saml_assertion,
      :policy,
      :duration_seconds)
      include Aws::Structure
    end

    # Contains the response to a successful AssumeRoleWithSAML request,
    # including temporary AWS credentials that can be used to make AWS
    # requests.
    #
    # @!attribute [rw] credentials
    #   The temporary security credentials, which include an access key ID,
    #   a secret access key, and a security (or session) token.
    #
    #   **Note:** The size of the security token that STS APIs return is not
    #   fixed. We strongly recommend that you make no assumptions about the
    #   maximum size. As of this writing, the typical size is less than 4096
    #   bytes, but that can vary. Also, future updates to AWS might require
    #   larger sizes.
    #   @return [Types::Credentials]
    #
    # @!attribute [rw] assumed_role_user
    #   The identifiers for the temporary security credentials that the
    #   operation returns.
    #   @return [Types::AssumedRoleUser]
    #
    # @!attribute [rw] packed_policy_size
    #   A percentage value that indicates the size of the policy in packed
    #   form. The service rejects any policy with a packed size greater than
    #   100 percent, which means the policy exceeded the allowed space.
    #   @return [Integer]
    #
    # @!attribute [rw] subject
    #   The value of the `NameID` element in the `Subject` element of the
    #   SAML assertion.
    #   @return [String]
    #
    # @!attribute [rw] subject_type
    #   The format of the name ID, as defined by the `Format` attribute in
    #   the `NameID` element of the SAML assertion. Typical examples of the
    #   format are `transient` or `persistent`.
    #
    #   If the format includes the prefix
    #   `urn:oasis:names:tc:SAML:2.0:nameid-format`, that prefix is removed.
    #   For example, `urn:oasis:names:tc:SAML:2.0:nameid-format:transient`
    #   is returned as `transient`. If the format includes any other prefix,
    #   the format is returned with no modifications.
    #   @return [String]
    #
    # @!attribute [rw] issuer
    #   The value of the `Issuer` element of the SAML assertion.
    #   @return [String]
    #
    # @!attribute [rw] audience
    #   The value of the `Recipient` attribute of the
    #   `SubjectConfirmationData` element of the SAML assertion.
    #   @return [String]
    #
    # @!attribute [rw] name_qualifier
    #   A hash value based on the concatenation of the `Issuer` response
    #   value, the AWS account ID, and the friendly name (the last part of
    #   the ARN) of the SAML provider in IAM. The combination of
    #   `NameQualifier` and `Subject` can be used to uniquely identify a
    #   federated user.
    #
    #   The following pseudocode shows how the hash value is calculated:
    #
    #   `BASE64 ( SHA1 ( "https://example.com/saml" + "123456789012" +
    #   "/MySAMLIdP" ) )`
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumeRoleWithSAMLResponse AWS API Documentation
    #
    class AssumeRoleWithSAMLResponse < Struct.new(
      :credentials,
      :assumed_role_user,
      :packed_policy_size,
      :subject,
      :subject_type,
      :issuer,
      :audience,
      :name_qualifier)
      include Aws::Structure
    end

    # @note When making an API call, you may pass AssumeRoleWithWebIdentityRequest
    #   data as a hash:
    #
    #       {
    #         role_arn: "arnType", # required
    #         role_session_name: "roleSessionNameType", # required
    #         web_identity_token: "clientTokenType", # required
    #         provider_id: "urlType",
    #         policy: "sessionPolicyDocumentType",
    #         duration_seconds: 1,
    #       }
    #
    # @!attribute [rw] role_arn
    #   The Amazon Resource Name (ARN) of the role that the caller is
    #   assuming.
    #   @return [String]
    #
    # @!attribute [rw] role_session_name
    #   An identifier for the assumed role session. Typically, you pass the
    #   name or identifier that is associated with the user who is using
    #   your application. That way, the temporary security credentials that
    #   your application will use are associated with that user. This
    #   session name is included as part of the ARN and assumed role ID in
    #   the `AssumedRoleUser` response element.
    #
    #   The regex used to validate this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@-
    #   @return [String]
    #
    # @!attribute [rw] web_identity_token
    #   The OAuth 2.0 access token or OpenID Connect ID token that is
    #   provided by the identity provider. Your application must get this
    #   token by authenticating the user who is using your application with
    #   a web identity provider before the application makes an
    #   `AssumeRoleWithWebIdentity` call.
    #   @return [String]
    #
    # @!attribute [rw] provider_id
    #   The fully qualified host component of the domain name of the
    #   identity provider.
    #
    #   Specify this value only for OAuth 2.0 access tokens. Currently
    #   `www.amazon.com` and `graph.facebook.com` are the only supported
    #   identity providers for OAuth 2.0 access tokens. Do not include URL
    #   schemes and port numbers.
    #
    #   Do not specify this value for OpenID Connect ID tokens.
    #   @return [String]
    #
    # @!attribute [rw] policy
    #   An IAM policy in JSON format.
    #
    #   The policy parameter is optional. If you pass a policy, the
    #   temporary security credentials that are returned by the operation
    #   have the permissions that are allowed by both the access policy of
    #   the role that is being assumed, <i> <b>and</b> </i> the policy that
    #   you pass. This gives you a way to further restrict the permissions
    #   for the resulting temporary security credentials. You cannot use the
    #   passed policy to grant permissions that are in excess of those
    #   allowed by the access policy of the role that is being assumed. For
    #   more information, see [Permissions for AssumeRoleWithWebIdentity][1]
    #   in the *IAM User Guide*.
    #
    #   The format for this parameter, as described by its regex pattern, is
    #   a string of characters up to 2048 characters in length. The
    #   characters can be any ASCII character from the space character to
    #   the end of the valid character list (\\u0020-\\u00FF). It can also
    #   include the tab (\\u0009), linefeed (\\u000A), and carriage return
    #   (\\u000D) characters.
    #
    #   <note markdown="1"> The policy plain text must be 2048 bytes or shorter. However, an
    #   internal conversion compresses it into a packed binary format with a
    #   separate limit. The PackedPolicySize response element indicates by
    #   percentage how close to the upper size limit the policy is, with
    #   100% equaling the maximum allowed size.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_assumerole.html
    #   @return [String]
    #
    # @!attribute [rw] duration_seconds
    #   The duration, in seconds, of the role session. The value can range
    #   from 900 seconds (15 minutes) up to the maximum session duration
    #   setting for the role. This setting can have a value from 1 hour to
    #   12 hours. If you specify a value higher than this setting, the
    #   operation fails. For example, if you specify a session duration of
    #   12 hours, but your administrator set the maximum session duration to
    #   6 hours, your operation fails. To learn how to view the maximum
    #   value for your role, see [View the Maximum Session Duration Setting
    #   for a Role][1] in the *IAM User Guide*.
    #
    #   By default, the value is set to 3600 seconds.
    #
    #   <note markdown="1"> The `DurationSeconds` parameter is separate from the duration of a
    #   console session that you might request using the returned
    #   credentials. The request to the federation endpoint for a console
    #   sign-in token takes a `SessionDuration` parameter that specifies the
    #   maximum length of the console session. For more information, see
    #   [Creating a URL that Enables Federated Users to Access the AWS
    #   Management Console][2] in the *IAM User Guide*.
    #
    #    </note>
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session
    #   [2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumeRoleWithWebIdentityRequest AWS API Documentation
    #
    class AssumeRoleWithWebIdentityRequest < Struct.new(
      :role_arn,
      :role_session_name,
      :web_identity_token,
      :provider_id,
      :policy,
      :duration_seconds)
      include Aws::Structure
    end

    # Contains the response to a successful AssumeRoleWithWebIdentity
    # request, including temporary AWS credentials that can be used to make
    # AWS requests.
    #
    # @!attribute [rw] credentials
    #   The temporary security credentials, which include an access key ID,
    #   a secret access key, and a security token.
    #
    #   **Note:** The size of the security token that STS APIs return is not
    #   fixed. We strongly recommend that you make no assumptions about the
    #   maximum size. As of this writing, the typical size is less than 4096
    #   bytes, but that can vary. Also, future updates to AWS might require
    #   larger sizes.
    #   @return [Types::Credentials]
    #
    # @!attribute [rw] subject_from_web_identity_token
    #   The unique user identifier that is returned by the identity
    #   provider. This identifier is associated with the `WebIdentityToken`
    #   that was submitted with the `AssumeRoleWithWebIdentity` call. The
    #   identifier is typically unique to the user and the application that
    #   acquired the `WebIdentityToken` (pairwise identifier). For OpenID
    #   Connect ID tokens, this field contains the value returned by the
    #   identity provider as the token's `sub` (Subject) claim.
    #   @return [String]
    #
    # @!attribute [rw] assumed_role_user
    #   The Amazon Resource Name (ARN) and the assumed role ID, which are
    #   identifiers that you can use to refer to the resulting temporary
    #   security credentials. For example, you can reference these
    #   credentials as a principal in a resource-based policy by using the
    #   ARN or assumed role ID. The ARN and ID include the `RoleSessionName`
    #   that you specified when you called `AssumeRole`.
    #   @return [Types::AssumedRoleUser]
    #
    # @!attribute [rw] packed_policy_size
    #   A percentage value that indicates the size of the policy in packed
    #   form. The service rejects any policy with a packed size greater than
    #   100 percent, which means the policy exceeded the allowed space.
    #   @return [Integer]
    #
    # @!attribute [rw] provider
    #   The issuing authority of the web identity token presented. For
    #   OpenID Connect ID Tokens this contains the value of the `iss` field.
    #   For OAuth 2.0 access tokens, this contains the value of the
    #   `ProviderId` parameter that was passed in the
    #   `AssumeRoleWithWebIdentity` request.
    #   @return [String]
    #
    # @!attribute [rw] audience
    #   The intended audience (also known as client ID) of the web identity
    #   token. This is traditionally the client identifier issued to the
    #   application that requested the web identity token.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumeRoleWithWebIdentityResponse AWS API Documentation
    #
    class AssumeRoleWithWebIdentityResponse < Struct.new(
      :credentials,
      :subject_from_web_identity_token,
      :assumed_role_user,
      :packed_policy_size,
      :provider,
      :audience)
      include Aws::Structure
    end

    # The identifiers for the temporary security credentials that the
    # operation returns.
    #
    # @!attribute [rw] assumed_role_id
    #   A unique identifier that contains the role ID and the role session
    #   name of the role that is being assumed. The role ID is generated by
    #   AWS when the role is created.
    #   @return [String]
    #
    # @!attribute [rw] arn
    #   The ARN of the temporary security credentials that are returned from
    #   the AssumeRole action. For more information about ARNs and how to
    #   use them in policies, see [IAM Identifiers][1] in *Using IAM*.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/AssumedRoleUser AWS API Documentation
    #
    class AssumedRoleUser < Struct.new(
      :assumed_role_id,
      :arn)
      include Aws::Structure
    end

    # AWS credentials for API authentication.
    #
    # @!attribute [rw] access_key_id
    #   The access key ID that identifies the temporary security
    #   credentials.
    #   @return [String]
    #
    # @!attribute [rw] secret_access_key
    #   The secret access key that can be used to sign requests.
    #   @return [String]
    #
    # @!attribute [rw] session_token
    #   The token that users must pass to the service API to use the
    #   temporary credentials.
    #   @return [String]
    #
    # @!attribute [rw] expiration
    #   The date on which the current credentials expire.
    #   @return [Time]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/Credentials AWS API Documentation
    #
    class Credentials < Struct.new(
      :access_key_id,
      :secret_access_key,
      :session_token,
      :expiration)
      include Aws::Structure
    end

    # @note When making an API call, you may pass DecodeAuthorizationMessageRequest
    #   data as a hash:
    #
    #       {
    #         encoded_message: "encodedMessageType", # required
    #       }
    #
    # @!attribute [rw] encoded_message
    #   The encoded message that was returned with the response.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/DecodeAuthorizationMessageRequest AWS API Documentation
    #
    class DecodeAuthorizationMessageRequest < Struct.new(
      :encoded_message)
      include Aws::Structure
    end

    # A document that contains additional information about the
    # authorization status of a request from an encoded message that is
    # returned in response to an AWS request.
    #
    # @!attribute [rw] decoded_message
    #   An XML document that contains the decoded message.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/DecodeAuthorizationMessageResponse AWS API Documentation
    #
    class DecodeAuthorizationMessageResponse < Struct.new(
      :decoded_message)
      include Aws::Structure
    end

    # Identifiers for the federated user that is associated with the
    # credentials.
    #
    # @!attribute [rw] federated_user_id
    #   The string that identifies the federated user associated with the
    #   credentials, similar to the unique ID of an IAM user.
    #   @return [String]
    #
    # @!attribute [rw] arn
    #   The ARN that specifies the federated user that is associated with
    #   the credentials. For more information about ARNs and how to use them
    #   in policies, see [IAM Identifiers][1] in *Using IAM*.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/FederatedUser AWS API Documentation
    #
    class FederatedUser < Struct.new(
      :federated_user_id,
      :arn)
      include Aws::Structure
    end

    # @api private
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/GetCallerIdentityRequest AWS API Documentation
    #
    class GetCallerIdentityRequest < Aws::EmptyStructure; end

    # Contains the response to a successful GetCallerIdentity request,
    # including information about the entity making the request.
    #
    # @!attribute [rw] user_id
    #   The unique identifier of the calling entity. The exact value depends
    #   on the type of entity making the call. The values returned are those
    #   listed in the **aws:userid** column in the [Principal table][1]
    #   found on the **Policy Variables** reference page in the *IAM User
    #   Guide*.
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_variables.html#principaltable
    #   @return [String]
    #
    # @!attribute [rw] account
    #   The AWS account ID number of the account that owns or contains the
    #   calling entity.
    #   @return [String]
    #
    # @!attribute [rw] arn
    #   The AWS ARN associated with the calling entity.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/GetCallerIdentityResponse AWS API Documentation
    #
    class GetCallerIdentityResponse < Struct.new(
      :user_id,
      :account,
      :arn)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetFederationTokenRequest
    #   data as a hash:
    #
    #       {
    #         name: "userNameType", # required
    #         policy: "sessionPolicyDocumentType",
    #         duration_seconds: 1,
    #       }
    #
    # @!attribute [rw] name
    #   The name of the federated user. The name is used as an identifier
    #   for the temporary security credentials (such as `Bob`). For example,
    #   you can reference the federated user name in a resource-based
    #   policy, such as in an Amazon S3 bucket policy.
    #
    #   The regex used to validate this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@-
    #   @return [String]
    #
    # @!attribute [rw] policy
    #   An IAM policy in JSON format that is passed with the
    #   `GetFederationToken` call and evaluated along with the policy or
    #   policies that are attached to the IAM user whose credentials are
    #   used to call `GetFederationToken`. The passed policy is used to
    #   scope down the permissions that are available to the IAM user, by
    #   allowing only a subset of the permissions that are granted to the
    #   IAM user. The passed policy cannot grant more permissions than those
    #   granted to the IAM user. The final permissions for the federated
    #   user are the most restrictive set based on the intersection of the
    #   passed policy and the IAM user policy.
    #
    #   If you do not pass a policy, the resulting temporary security
    #   credentials have no effective permissions. The only exception is
    #   when the temporary security credentials are used to access a
    #   resource that has a resource-based policy that specifically allows
    #   the federated user to access the resource.
    #
    #   The format for this parameter, as described by its regex pattern, is
    #   a string of characters up to 2048 characters in length. The
    #   characters can be any ASCII character from the space character to
    #   the end of the valid character list (\\u0020-\\u00FF). It can also
    #   include the tab (\\u0009), linefeed (\\u000A), and carriage return
    #   (\\u000D) characters.
    #
    #   <note markdown="1"> The policy plain text must be 2048 bytes or shorter. However, an
    #   internal conversion compresses it into a packed binary format with a
    #   separate limit. The PackedPolicySize response element indicates by
    #   percentage how close to the upper size limit the policy is, with
    #   100% equaling the maximum allowed size.
    #
    #    </note>
    #
    #   For more information about how permissions work, see [Permissions
    #   for GetFederationToken][1].
    #
    #
    #
    #   [1]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_getfederationtoken.html
    #   @return [String]
    #
    # @!attribute [rw] duration_seconds
    #   The duration, in seconds, that the session should last. Acceptable
    #   durations for federation sessions range from 900 seconds (15
    #   minutes) to 129600 seconds (36 hours), with 43200 seconds (12 hours)
    #   as the default. Sessions obtained using AWS account (root)
    #   credentials are restricted to a maximum of 3600 seconds (one hour).
    #   If the specified duration is longer than one hour, the session
    #   obtained by using AWS account (root) credentials defaults to one
    #   hour.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/GetFederationTokenRequest AWS API Documentation
    #
    class GetFederationTokenRequest < Struct.new(
      :name,
      :policy,
      :duration_seconds)
      include Aws::Structure
    end

    # Contains the response to a successful GetFederationToken request,
    # including temporary AWS credentials that can be used to make AWS
    # requests.
    #
    # @!attribute [rw] credentials
    #   The temporary security credentials, which include an access key ID,
    #   a secret access key, and a security (or session) token.
    #
    #   **Note:** The size of the security token that STS APIs return is not
    #   fixed. We strongly recommend that you make no assumptions about the
    #   maximum size. As of this writing, the typical size is less than 4096
    #   bytes, but that can vary. Also, future updates to AWS might require
    #   larger sizes.
    #   @return [Types::Credentials]
    #
    # @!attribute [rw] federated_user
    #   Identifiers for the federated user associated with the credentials
    #   (such as `arn:aws:sts::123456789012:federated-user/Bob` or
    #   `123456789012:Bob`). You can use the federated user's ARN in your
    #   resource-based policies, such as an Amazon S3 bucket policy.
    #   @return [Types::FederatedUser]
    #
    # @!attribute [rw] packed_policy_size
    #   A percentage value indicating the size of the policy in packed form.
    #   The service rejects policies for which the packed size is greater
    #   than 100 percent of the allowed value.
    #   @return [Integer]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/GetFederationTokenResponse AWS API Documentation
    #
    class GetFederationTokenResponse < Struct.new(
      :credentials,
      :federated_user,
      :packed_policy_size)
      include Aws::Structure
    end

    # @note When making an API call, you may pass GetSessionTokenRequest
    #   data as a hash:
    #
    #       {
    #         duration_seconds: 1,
    #         serial_number: "serialNumberType",
    #         token_code: "tokenCodeType",
    #       }
    #
    # @!attribute [rw] duration_seconds
    #   The duration, in seconds, that the credentials should remain valid.
    #   Acceptable durations for IAM user sessions range from 900 seconds
    #   (15 minutes) to 129600 seconds (36 hours), with 43200 seconds (12
    #   hours) as the default. Sessions for AWS account owners are
    #   restricted to a maximum of 3600 seconds (one hour). If the duration
    #   is longer than one hour, the session for AWS account owners defaults
    #   to one hour.
    #   @return [Integer]
    #
    # @!attribute [rw] serial_number
    #   The identification number of the MFA device that is associated with
    #   the IAM user who is making the `GetSessionToken` call. Specify this
    #   value if the IAM user has a policy that requires MFA authentication.
    #   The value is either the serial number for a hardware device (such as
    #   `GAHT12345678`) or an Amazon Resource Name (ARN) for a virtual
    #   device (such as `arn:aws:iam::123456789012:mfa/user`). You can find
    #   the device for an IAM user by going to the AWS Management Console
    #   and viewing the user's security credentials.
    #
    #   The regex used to validated this parameter is a string of characters
    #   consisting of upper- and lower-case alphanumeric characters with no
    #   spaces. You can also include underscores or any of the following
    #   characters: =,.@:/-
    #   @return [String]
    #
    # @!attribute [rw] token_code
    #   The value provided by the MFA device, if MFA is required. If any
    #   policy requires the IAM user to submit an MFA code, specify this
    #   value. If MFA authentication is required, and the user does not
    #   provide a code when requesting a set of temporary security
    #   credentials, the user will receive an "access denied" response
    #   when requesting resources that require MFA authentication.
    #
    #   The format for this parameter, as described by its regex pattern, is
    #   a sequence of six numeric digits.
    #   @return [String]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/GetSessionTokenRequest AWS API Documentation
    #
    class GetSessionTokenRequest < Struct.new(
      :duration_seconds,
      :serial_number,
      :token_code)
      include Aws::Structure
    end

    # Contains the response to a successful GetSessionToken request,
    # including temporary AWS credentials that can be used to make AWS
    # requests.
    #
    # @!attribute [rw] credentials
    #   The temporary security credentials, which include an access key ID,
    #   a secret access key, and a security (or session) token.
    #
    #   **Note:** The size of the security token that STS APIs return is not
    #   fixed. We strongly recommend that you make no assumptions about the
    #   maximum size. As of this writing, the typical size is less than 4096
    #   bytes, but that can vary. Also, future updates to AWS might require
    #   larger sizes.
    #   @return [Types::Credentials]
    #
    # @see http://docs.aws.amazon.com/goto/WebAPI/sts-2011-06-15/GetSessionTokenResponse AWS API Documentation
    #
    class GetSessionTokenResponse < Struct.new(
      :credentials)
      include Aws::Structure
    end

  end
end
