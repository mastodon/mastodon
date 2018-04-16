# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

module Aws::KMS
  # @api private
  module ClientApi

    include Seahorse::Model

    AWSAccountIdType = Shapes::StringShape.new(name: 'AWSAccountIdType')
    AlgorithmSpec = Shapes::StringShape.new(name: 'AlgorithmSpec')
    AliasList = Shapes::ListShape.new(name: 'AliasList')
    AliasListEntry = Shapes::StructureShape.new(name: 'AliasListEntry')
    AliasNameType = Shapes::StringShape.new(name: 'AliasNameType')
    AlreadyExistsException = Shapes::StructureShape.new(name: 'AlreadyExistsException')
    ArnType = Shapes::StringShape.new(name: 'ArnType')
    BooleanType = Shapes::BooleanShape.new(name: 'BooleanType')
    CancelKeyDeletionRequest = Shapes::StructureShape.new(name: 'CancelKeyDeletionRequest')
    CancelKeyDeletionResponse = Shapes::StructureShape.new(name: 'CancelKeyDeletionResponse')
    CiphertextType = Shapes::BlobShape.new(name: 'CiphertextType')
    CreateAliasRequest = Shapes::StructureShape.new(name: 'CreateAliasRequest')
    CreateGrantRequest = Shapes::StructureShape.new(name: 'CreateGrantRequest')
    CreateGrantResponse = Shapes::StructureShape.new(name: 'CreateGrantResponse')
    CreateKeyRequest = Shapes::StructureShape.new(name: 'CreateKeyRequest')
    CreateKeyResponse = Shapes::StructureShape.new(name: 'CreateKeyResponse')
    DataKeySpec = Shapes::StringShape.new(name: 'DataKeySpec')
    DateType = Shapes::TimestampShape.new(name: 'DateType')
    DecryptRequest = Shapes::StructureShape.new(name: 'DecryptRequest')
    DecryptResponse = Shapes::StructureShape.new(name: 'DecryptResponse')
    DeleteAliasRequest = Shapes::StructureShape.new(name: 'DeleteAliasRequest')
    DeleteImportedKeyMaterialRequest = Shapes::StructureShape.new(name: 'DeleteImportedKeyMaterialRequest')
    DependencyTimeoutException = Shapes::StructureShape.new(name: 'DependencyTimeoutException')
    DescribeKeyRequest = Shapes::StructureShape.new(name: 'DescribeKeyRequest')
    DescribeKeyResponse = Shapes::StructureShape.new(name: 'DescribeKeyResponse')
    DescriptionType = Shapes::StringShape.new(name: 'DescriptionType')
    DisableKeyRequest = Shapes::StructureShape.new(name: 'DisableKeyRequest')
    DisableKeyRotationRequest = Shapes::StructureShape.new(name: 'DisableKeyRotationRequest')
    DisabledException = Shapes::StructureShape.new(name: 'DisabledException')
    EnableKeyRequest = Shapes::StructureShape.new(name: 'EnableKeyRequest')
    EnableKeyRotationRequest = Shapes::StructureShape.new(name: 'EnableKeyRotationRequest')
    EncryptRequest = Shapes::StructureShape.new(name: 'EncryptRequest')
    EncryptResponse = Shapes::StructureShape.new(name: 'EncryptResponse')
    EncryptionContextKey = Shapes::StringShape.new(name: 'EncryptionContextKey')
    EncryptionContextType = Shapes::MapShape.new(name: 'EncryptionContextType')
    EncryptionContextValue = Shapes::StringShape.new(name: 'EncryptionContextValue')
    ErrorMessageType = Shapes::StringShape.new(name: 'ErrorMessageType')
    ExpirationModelType = Shapes::StringShape.new(name: 'ExpirationModelType')
    ExpiredImportTokenException = Shapes::StructureShape.new(name: 'ExpiredImportTokenException')
    GenerateDataKeyRequest = Shapes::StructureShape.new(name: 'GenerateDataKeyRequest')
    GenerateDataKeyResponse = Shapes::StructureShape.new(name: 'GenerateDataKeyResponse')
    GenerateDataKeyWithoutPlaintextRequest = Shapes::StructureShape.new(name: 'GenerateDataKeyWithoutPlaintextRequest')
    GenerateDataKeyWithoutPlaintextResponse = Shapes::StructureShape.new(name: 'GenerateDataKeyWithoutPlaintextResponse')
    GenerateRandomRequest = Shapes::StructureShape.new(name: 'GenerateRandomRequest')
    GenerateRandomResponse = Shapes::StructureShape.new(name: 'GenerateRandomResponse')
    GetKeyPolicyRequest = Shapes::StructureShape.new(name: 'GetKeyPolicyRequest')
    GetKeyPolicyResponse = Shapes::StructureShape.new(name: 'GetKeyPolicyResponse')
    GetKeyRotationStatusRequest = Shapes::StructureShape.new(name: 'GetKeyRotationStatusRequest')
    GetKeyRotationStatusResponse = Shapes::StructureShape.new(name: 'GetKeyRotationStatusResponse')
    GetParametersForImportRequest = Shapes::StructureShape.new(name: 'GetParametersForImportRequest')
    GetParametersForImportResponse = Shapes::StructureShape.new(name: 'GetParametersForImportResponse')
    GrantConstraints = Shapes::StructureShape.new(name: 'GrantConstraints')
    GrantIdType = Shapes::StringShape.new(name: 'GrantIdType')
    GrantList = Shapes::ListShape.new(name: 'GrantList')
    GrantListEntry = Shapes::StructureShape.new(name: 'GrantListEntry')
    GrantNameType = Shapes::StringShape.new(name: 'GrantNameType')
    GrantOperation = Shapes::StringShape.new(name: 'GrantOperation')
    GrantOperationList = Shapes::ListShape.new(name: 'GrantOperationList')
    GrantTokenList = Shapes::ListShape.new(name: 'GrantTokenList')
    GrantTokenType = Shapes::StringShape.new(name: 'GrantTokenType')
    ImportKeyMaterialRequest = Shapes::StructureShape.new(name: 'ImportKeyMaterialRequest')
    ImportKeyMaterialResponse = Shapes::StructureShape.new(name: 'ImportKeyMaterialResponse')
    IncorrectKeyMaterialException = Shapes::StructureShape.new(name: 'IncorrectKeyMaterialException')
    InvalidAliasNameException = Shapes::StructureShape.new(name: 'InvalidAliasNameException')
    InvalidArnException = Shapes::StructureShape.new(name: 'InvalidArnException')
    InvalidCiphertextException = Shapes::StructureShape.new(name: 'InvalidCiphertextException')
    InvalidGrantIdException = Shapes::StructureShape.new(name: 'InvalidGrantIdException')
    InvalidGrantTokenException = Shapes::StructureShape.new(name: 'InvalidGrantTokenException')
    InvalidImportTokenException = Shapes::StructureShape.new(name: 'InvalidImportTokenException')
    InvalidKeyUsageException = Shapes::StructureShape.new(name: 'InvalidKeyUsageException')
    InvalidMarkerException = Shapes::StructureShape.new(name: 'InvalidMarkerException')
    KMSInternalException = Shapes::StructureShape.new(name: 'KMSInternalException')
    KMSInvalidStateException = Shapes::StructureShape.new(name: 'KMSInvalidStateException')
    KeyIdType = Shapes::StringShape.new(name: 'KeyIdType')
    KeyList = Shapes::ListShape.new(name: 'KeyList')
    KeyListEntry = Shapes::StructureShape.new(name: 'KeyListEntry')
    KeyManagerType = Shapes::StringShape.new(name: 'KeyManagerType')
    KeyMetadata = Shapes::StructureShape.new(name: 'KeyMetadata')
    KeyState = Shapes::StringShape.new(name: 'KeyState')
    KeyUnavailableException = Shapes::StructureShape.new(name: 'KeyUnavailableException')
    KeyUsageType = Shapes::StringShape.new(name: 'KeyUsageType')
    LimitExceededException = Shapes::StructureShape.new(name: 'LimitExceededException')
    LimitType = Shapes::IntegerShape.new(name: 'LimitType')
    ListAliasesRequest = Shapes::StructureShape.new(name: 'ListAliasesRequest')
    ListAliasesResponse = Shapes::StructureShape.new(name: 'ListAliasesResponse')
    ListGrantsRequest = Shapes::StructureShape.new(name: 'ListGrantsRequest')
    ListGrantsResponse = Shapes::StructureShape.new(name: 'ListGrantsResponse')
    ListKeyPoliciesRequest = Shapes::StructureShape.new(name: 'ListKeyPoliciesRequest')
    ListKeyPoliciesResponse = Shapes::StructureShape.new(name: 'ListKeyPoliciesResponse')
    ListKeysRequest = Shapes::StructureShape.new(name: 'ListKeysRequest')
    ListKeysResponse = Shapes::StructureShape.new(name: 'ListKeysResponse')
    ListResourceTagsRequest = Shapes::StructureShape.new(name: 'ListResourceTagsRequest')
    ListResourceTagsResponse = Shapes::StructureShape.new(name: 'ListResourceTagsResponse')
    ListRetirableGrantsRequest = Shapes::StructureShape.new(name: 'ListRetirableGrantsRequest')
    MalformedPolicyDocumentException = Shapes::StructureShape.new(name: 'MalformedPolicyDocumentException')
    MarkerType = Shapes::StringShape.new(name: 'MarkerType')
    NotFoundException = Shapes::StructureShape.new(name: 'NotFoundException')
    NumberOfBytesType = Shapes::IntegerShape.new(name: 'NumberOfBytesType')
    OriginType = Shapes::StringShape.new(name: 'OriginType')
    PendingWindowInDaysType = Shapes::IntegerShape.new(name: 'PendingWindowInDaysType')
    PlaintextType = Shapes::BlobShape.new(name: 'PlaintextType')
    PolicyNameList = Shapes::ListShape.new(name: 'PolicyNameList')
    PolicyNameType = Shapes::StringShape.new(name: 'PolicyNameType')
    PolicyType = Shapes::StringShape.new(name: 'PolicyType')
    PrincipalIdType = Shapes::StringShape.new(name: 'PrincipalIdType')
    PutKeyPolicyRequest = Shapes::StructureShape.new(name: 'PutKeyPolicyRequest')
    ReEncryptRequest = Shapes::StructureShape.new(name: 'ReEncryptRequest')
    ReEncryptResponse = Shapes::StructureShape.new(name: 'ReEncryptResponse')
    RetireGrantRequest = Shapes::StructureShape.new(name: 'RetireGrantRequest')
    RevokeGrantRequest = Shapes::StructureShape.new(name: 'RevokeGrantRequest')
    ScheduleKeyDeletionRequest = Shapes::StructureShape.new(name: 'ScheduleKeyDeletionRequest')
    ScheduleKeyDeletionResponse = Shapes::StructureShape.new(name: 'ScheduleKeyDeletionResponse')
    Tag = Shapes::StructureShape.new(name: 'Tag')
    TagException = Shapes::StructureShape.new(name: 'TagException')
    TagKeyList = Shapes::ListShape.new(name: 'TagKeyList')
    TagKeyType = Shapes::StringShape.new(name: 'TagKeyType')
    TagList = Shapes::ListShape.new(name: 'TagList')
    TagResourceRequest = Shapes::StructureShape.new(name: 'TagResourceRequest')
    TagValueType = Shapes::StringShape.new(name: 'TagValueType')
    UnsupportedOperationException = Shapes::StructureShape.new(name: 'UnsupportedOperationException')
    UntagResourceRequest = Shapes::StructureShape.new(name: 'UntagResourceRequest')
    UpdateAliasRequest = Shapes::StructureShape.new(name: 'UpdateAliasRequest')
    UpdateKeyDescriptionRequest = Shapes::StructureShape.new(name: 'UpdateKeyDescriptionRequest')
    WrappingKeySpec = Shapes::StringShape.new(name: 'WrappingKeySpec')

    AliasList.member = Shapes::ShapeRef.new(shape: AliasListEntry)

    AliasListEntry.add_member(:alias_name, Shapes::ShapeRef.new(shape: AliasNameType, location_name: "AliasName"))
    AliasListEntry.add_member(:alias_arn, Shapes::ShapeRef.new(shape: ArnType, location_name: "AliasArn"))
    AliasListEntry.add_member(:target_key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "TargetKeyId"))
    AliasListEntry.struct_class = Types::AliasListEntry

    CancelKeyDeletionRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    CancelKeyDeletionRequest.struct_class = Types::CancelKeyDeletionRequest

    CancelKeyDeletionResponse.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    CancelKeyDeletionResponse.struct_class = Types::CancelKeyDeletionResponse

    CreateAliasRequest.add_member(:alias_name, Shapes::ShapeRef.new(shape: AliasNameType, required: true, location_name: "AliasName"))
    CreateAliasRequest.add_member(:target_key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "TargetKeyId"))
    CreateAliasRequest.struct_class = Types::CreateAliasRequest

    CreateGrantRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    CreateGrantRequest.add_member(:grantee_principal, Shapes::ShapeRef.new(shape: PrincipalIdType, required: true, location_name: "GranteePrincipal"))
    CreateGrantRequest.add_member(:retiring_principal, Shapes::ShapeRef.new(shape: PrincipalIdType, location_name: "RetiringPrincipal"))
    CreateGrantRequest.add_member(:operations, Shapes::ShapeRef.new(shape: GrantOperationList, required: true, location_name: "Operations"))
    CreateGrantRequest.add_member(:constraints, Shapes::ShapeRef.new(shape: GrantConstraints, location_name: "Constraints"))
    CreateGrantRequest.add_member(:grant_tokens, Shapes::ShapeRef.new(shape: GrantTokenList, location_name: "GrantTokens"))
    CreateGrantRequest.add_member(:name, Shapes::ShapeRef.new(shape: GrantNameType, location_name: "Name"))
    CreateGrantRequest.struct_class = Types::CreateGrantRequest

    CreateGrantResponse.add_member(:grant_token, Shapes::ShapeRef.new(shape: GrantTokenType, location_name: "GrantToken"))
    CreateGrantResponse.add_member(:grant_id, Shapes::ShapeRef.new(shape: GrantIdType, location_name: "GrantId"))
    CreateGrantResponse.struct_class = Types::CreateGrantResponse

    CreateKeyRequest.add_member(:policy, Shapes::ShapeRef.new(shape: PolicyType, location_name: "Policy"))
    CreateKeyRequest.add_member(:description, Shapes::ShapeRef.new(shape: DescriptionType, location_name: "Description"))
    CreateKeyRequest.add_member(:key_usage, Shapes::ShapeRef.new(shape: KeyUsageType, location_name: "KeyUsage"))
    CreateKeyRequest.add_member(:origin, Shapes::ShapeRef.new(shape: OriginType, location_name: "Origin"))
    CreateKeyRequest.add_member(:bypass_policy_lockout_safety_check, Shapes::ShapeRef.new(shape: BooleanType, location_name: "BypassPolicyLockoutSafetyCheck"))
    CreateKeyRequest.add_member(:tags, Shapes::ShapeRef.new(shape: TagList, location_name: "Tags"))
    CreateKeyRequest.struct_class = Types::CreateKeyRequest

    CreateKeyResponse.add_member(:key_metadata, Shapes::ShapeRef.new(shape: KeyMetadata, location_name: "KeyMetadata"))
    CreateKeyResponse.struct_class = Types::CreateKeyResponse

    DecryptRequest.add_member(:ciphertext_blob, Shapes::ShapeRef.new(shape: CiphertextType, required: true, location_name: "CiphertextBlob"))
    DecryptRequest.add_member(:encryption_context, Shapes::ShapeRef.new(shape: EncryptionContextType, location_name: "EncryptionContext"))
    DecryptRequest.add_member(:grant_tokens, Shapes::ShapeRef.new(shape: GrantTokenList, location_name: "GrantTokens"))
    DecryptRequest.struct_class = Types::DecryptRequest

    DecryptResponse.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    DecryptResponse.add_member(:plaintext, Shapes::ShapeRef.new(shape: PlaintextType, location_name: "Plaintext"))
    DecryptResponse.struct_class = Types::DecryptResponse

    DeleteAliasRequest.add_member(:alias_name, Shapes::ShapeRef.new(shape: AliasNameType, required: true, location_name: "AliasName"))
    DeleteAliasRequest.struct_class = Types::DeleteAliasRequest

    DeleteImportedKeyMaterialRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    DeleteImportedKeyMaterialRequest.struct_class = Types::DeleteImportedKeyMaterialRequest

    DescribeKeyRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    DescribeKeyRequest.add_member(:grant_tokens, Shapes::ShapeRef.new(shape: GrantTokenList, location_name: "GrantTokens"))
    DescribeKeyRequest.struct_class = Types::DescribeKeyRequest

    DescribeKeyResponse.add_member(:key_metadata, Shapes::ShapeRef.new(shape: KeyMetadata, location_name: "KeyMetadata"))
    DescribeKeyResponse.struct_class = Types::DescribeKeyResponse

    DisableKeyRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    DisableKeyRequest.struct_class = Types::DisableKeyRequest

    DisableKeyRotationRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    DisableKeyRotationRequest.struct_class = Types::DisableKeyRotationRequest

    EnableKeyRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    EnableKeyRequest.struct_class = Types::EnableKeyRequest

    EnableKeyRotationRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    EnableKeyRotationRequest.struct_class = Types::EnableKeyRotationRequest

    EncryptRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    EncryptRequest.add_member(:plaintext, Shapes::ShapeRef.new(shape: PlaintextType, required: true, location_name: "Plaintext"))
    EncryptRequest.add_member(:encryption_context, Shapes::ShapeRef.new(shape: EncryptionContextType, location_name: "EncryptionContext"))
    EncryptRequest.add_member(:grant_tokens, Shapes::ShapeRef.new(shape: GrantTokenList, location_name: "GrantTokens"))
    EncryptRequest.struct_class = Types::EncryptRequest

    EncryptResponse.add_member(:ciphertext_blob, Shapes::ShapeRef.new(shape: CiphertextType, location_name: "CiphertextBlob"))
    EncryptResponse.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    EncryptResponse.struct_class = Types::EncryptResponse

    EncryptionContextType.key = Shapes::ShapeRef.new(shape: EncryptionContextKey)
    EncryptionContextType.value = Shapes::ShapeRef.new(shape: EncryptionContextValue)

    GenerateDataKeyRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    GenerateDataKeyRequest.add_member(:encryption_context, Shapes::ShapeRef.new(shape: EncryptionContextType, location_name: "EncryptionContext"))
    GenerateDataKeyRequest.add_member(:number_of_bytes, Shapes::ShapeRef.new(shape: NumberOfBytesType, location_name: "NumberOfBytes"))
    GenerateDataKeyRequest.add_member(:key_spec, Shapes::ShapeRef.new(shape: DataKeySpec, location_name: "KeySpec"))
    GenerateDataKeyRequest.add_member(:grant_tokens, Shapes::ShapeRef.new(shape: GrantTokenList, location_name: "GrantTokens"))
    GenerateDataKeyRequest.struct_class = Types::GenerateDataKeyRequest

    GenerateDataKeyResponse.add_member(:ciphertext_blob, Shapes::ShapeRef.new(shape: CiphertextType, location_name: "CiphertextBlob"))
    GenerateDataKeyResponse.add_member(:plaintext, Shapes::ShapeRef.new(shape: PlaintextType, location_name: "Plaintext"))
    GenerateDataKeyResponse.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    GenerateDataKeyResponse.struct_class = Types::GenerateDataKeyResponse

    GenerateDataKeyWithoutPlaintextRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    GenerateDataKeyWithoutPlaintextRequest.add_member(:encryption_context, Shapes::ShapeRef.new(shape: EncryptionContextType, location_name: "EncryptionContext"))
    GenerateDataKeyWithoutPlaintextRequest.add_member(:key_spec, Shapes::ShapeRef.new(shape: DataKeySpec, location_name: "KeySpec"))
    GenerateDataKeyWithoutPlaintextRequest.add_member(:number_of_bytes, Shapes::ShapeRef.new(shape: NumberOfBytesType, location_name: "NumberOfBytes"))
    GenerateDataKeyWithoutPlaintextRequest.add_member(:grant_tokens, Shapes::ShapeRef.new(shape: GrantTokenList, location_name: "GrantTokens"))
    GenerateDataKeyWithoutPlaintextRequest.struct_class = Types::GenerateDataKeyWithoutPlaintextRequest

    GenerateDataKeyWithoutPlaintextResponse.add_member(:ciphertext_blob, Shapes::ShapeRef.new(shape: CiphertextType, location_name: "CiphertextBlob"))
    GenerateDataKeyWithoutPlaintextResponse.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    GenerateDataKeyWithoutPlaintextResponse.struct_class = Types::GenerateDataKeyWithoutPlaintextResponse

    GenerateRandomRequest.add_member(:number_of_bytes, Shapes::ShapeRef.new(shape: NumberOfBytesType, location_name: "NumberOfBytes"))
    GenerateRandomRequest.struct_class = Types::GenerateRandomRequest

    GenerateRandomResponse.add_member(:plaintext, Shapes::ShapeRef.new(shape: PlaintextType, location_name: "Plaintext"))
    GenerateRandomResponse.struct_class = Types::GenerateRandomResponse

    GetKeyPolicyRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    GetKeyPolicyRequest.add_member(:policy_name, Shapes::ShapeRef.new(shape: PolicyNameType, required: true, location_name: "PolicyName"))
    GetKeyPolicyRequest.struct_class = Types::GetKeyPolicyRequest

    GetKeyPolicyResponse.add_member(:policy, Shapes::ShapeRef.new(shape: PolicyType, location_name: "Policy"))
    GetKeyPolicyResponse.struct_class = Types::GetKeyPolicyResponse

    GetKeyRotationStatusRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    GetKeyRotationStatusRequest.struct_class = Types::GetKeyRotationStatusRequest

    GetKeyRotationStatusResponse.add_member(:key_rotation_enabled, Shapes::ShapeRef.new(shape: BooleanType, location_name: "KeyRotationEnabled"))
    GetKeyRotationStatusResponse.struct_class = Types::GetKeyRotationStatusResponse

    GetParametersForImportRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    GetParametersForImportRequest.add_member(:wrapping_algorithm, Shapes::ShapeRef.new(shape: AlgorithmSpec, required: true, location_name: "WrappingAlgorithm"))
    GetParametersForImportRequest.add_member(:wrapping_key_spec, Shapes::ShapeRef.new(shape: WrappingKeySpec, required: true, location_name: "WrappingKeySpec"))
    GetParametersForImportRequest.struct_class = Types::GetParametersForImportRequest

    GetParametersForImportResponse.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    GetParametersForImportResponse.add_member(:import_token, Shapes::ShapeRef.new(shape: CiphertextType, location_name: "ImportToken"))
    GetParametersForImportResponse.add_member(:public_key, Shapes::ShapeRef.new(shape: PlaintextType, location_name: "PublicKey"))
    GetParametersForImportResponse.add_member(:parameters_valid_to, Shapes::ShapeRef.new(shape: DateType, location_name: "ParametersValidTo"))
    GetParametersForImportResponse.struct_class = Types::GetParametersForImportResponse

    GrantConstraints.add_member(:encryption_context_subset, Shapes::ShapeRef.new(shape: EncryptionContextType, location_name: "EncryptionContextSubset"))
    GrantConstraints.add_member(:encryption_context_equals, Shapes::ShapeRef.new(shape: EncryptionContextType, location_name: "EncryptionContextEquals"))
    GrantConstraints.struct_class = Types::GrantConstraints

    GrantList.member = Shapes::ShapeRef.new(shape: GrantListEntry)

    GrantListEntry.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    GrantListEntry.add_member(:grant_id, Shapes::ShapeRef.new(shape: GrantIdType, location_name: "GrantId"))
    GrantListEntry.add_member(:name, Shapes::ShapeRef.new(shape: GrantNameType, location_name: "Name"))
    GrantListEntry.add_member(:creation_date, Shapes::ShapeRef.new(shape: DateType, location_name: "CreationDate"))
    GrantListEntry.add_member(:grantee_principal, Shapes::ShapeRef.new(shape: PrincipalIdType, location_name: "GranteePrincipal"))
    GrantListEntry.add_member(:retiring_principal, Shapes::ShapeRef.new(shape: PrincipalIdType, location_name: "RetiringPrincipal"))
    GrantListEntry.add_member(:issuing_account, Shapes::ShapeRef.new(shape: PrincipalIdType, location_name: "IssuingAccount"))
    GrantListEntry.add_member(:operations, Shapes::ShapeRef.new(shape: GrantOperationList, location_name: "Operations"))
    GrantListEntry.add_member(:constraints, Shapes::ShapeRef.new(shape: GrantConstraints, location_name: "Constraints"))
    GrantListEntry.struct_class = Types::GrantListEntry

    GrantOperationList.member = Shapes::ShapeRef.new(shape: GrantOperation)

    GrantTokenList.member = Shapes::ShapeRef.new(shape: GrantTokenType)

    ImportKeyMaterialRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    ImportKeyMaterialRequest.add_member(:import_token, Shapes::ShapeRef.new(shape: CiphertextType, required: true, location_name: "ImportToken"))
    ImportKeyMaterialRequest.add_member(:encrypted_key_material, Shapes::ShapeRef.new(shape: CiphertextType, required: true, location_name: "EncryptedKeyMaterial"))
    ImportKeyMaterialRequest.add_member(:valid_to, Shapes::ShapeRef.new(shape: DateType, location_name: "ValidTo"))
    ImportKeyMaterialRequest.add_member(:expiration_model, Shapes::ShapeRef.new(shape: ExpirationModelType, location_name: "ExpirationModel"))
    ImportKeyMaterialRequest.struct_class = Types::ImportKeyMaterialRequest

    ImportKeyMaterialResponse.struct_class = Types::ImportKeyMaterialResponse

    KeyList.member = Shapes::ShapeRef.new(shape: KeyListEntry)

    KeyListEntry.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    KeyListEntry.add_member(:key_arn, Shapes::ShapeRef.new(shape: ArnType, location_name: "KeyArn"))
    KeyListEntry.struct_class = Types::KeyListEntry

    KeyMetadata.add_member(:aws_account_id, Shapes::ShapeRef.new(shape: AWSAccountIdType, location_name: "AWSAccountId"))
    KeyMetadata.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    KeyMetadata.add_member(:arn, Shapes::ShapeRef.new(shape: ArnType, location_name: "Arn"))
    KeyMetadata.add_member(:creation_date, Shapes::ShapeRef.new(shape: DateType, location_name: "CreationDate"))
    KeyMetadata.add_member(:enabled, Shapes::ShapeRef.new(shape: BooleanType, location_name: "Enabled"))
    KeyMetadata.add_member(:description, Shapes::ShapeRef.new(shape: DescriptionType, location_name: "Description"))
    KeyMetadata.add_member(:key_usage, Shapes::ShapeRef.new(shape: KeyUsageType, location_name: "KeyUsage"))
    KeyMetadata.add_member(:key_state, Shapes::ShapeRef.new(shape: KeyState, location_name: "KeyState"))
    KeyMetadata.add_member(:deletion_date, Shapes::ShapeRef.new(shape: DateType, location_name: "DeletionDate"))
    KeyMetadata.add_member(:valid_to, Shapes::ShapeRef.new(shape: DateType, location_name: "ValidTo"))
    KeyMetadata.add_member(:origin, Shapes::ShapeRef.new(shape: OriginType, location_name: "Origin"))
    KeyMetadata.add_member(:expiration_model, Shapes::ShapeRef.new(shape: ExpirationModelType, location_name: "ExpirationModel"))
    KeyMetadata.add_member(:key_manager, Shapes::ShapeRef.new(shape: KeyManagerType, location_name: "KeyManager"))
    KeyMetadata.struct_class = Types::KeyMetadata

    ListAliasesRequest.add_member(:limit, Shapes::ShapeRef.new(shape: LimitType, location_name: "Limit"))
    ListAliasesRequest.add_member(:marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "Marker"))
    ListAliasesRequest.struct_class = Types::ListAliasesRequest

    ListAliasesResponse.add_member(:aliases, Shapes::ShapeRef.new(shape: AliasList, location_name: "Aliases"))
    ListAliasesResponse.add_member(:next_marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "NextMarker"))
    ListAliasesResponse.add_member(:truncated, Shapes::ShapeRef.new(shape: BooleanType, location_name: "Truncated"))
    ListAliasesResponse.struct_class = Types::ListAliasesResponse

    ListGrantsRequest.add_member(:limit, Shapes::ShapeRef.new(shape: LimitType, location_name: "Limit"))
    ListGrantsRequest.add_member(:marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "Marker"))
    ListGrantsRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    ListGrantsRequest.struct_class = Types::ListGrantsRequest

    ListGrantsResponse.add_member(:grants, Shapes::ShapeRef.new(shape: GrantList, location_name: "Grants"))
    ListGrantsResponse.add_member(:next_marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "NextMarker"))
    ListGrantsResponse.add_member(:truncated, Shapes::ShapeRef.new(shape: BooleanType, location_name: "Truncated"))
    ListGrantsResponse.struct_class = Types::ListGrantsResponse

    ListKeyPoliciesRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    ListKeyPoliciesRequest.add_member(:limit, Shapes::ShapeRef.new(shape: LimitType, location_name: "Limit"))
    ListKeyPoliciesRequest.add_member(:marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "Marker"))
    ListKeyPoliciesRequest.struct_class = Types::ListKeyPoliciesRequest

    ListKeyPoliciesResponse.add_member(:policy_names, Shapes::ShapeRef.new(shape: PolicyNameList, location_name: "PolicyNames"))
    ListKeyPoliciesResponse.add_member(:next_marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "NextMarker"))
    ListKeyPoliciesResponse.add_member(:truncated, Shapes::ShapeRef.new(shape: BooleanType, location_name: "Truncated"))
    ListKeyPoliciesResponse.struct_class = Types::ListKeyPoliciesResponse

    ListKeysRequest.add_member(:limit, Shapes::ShapeRef.new(shape: LimitType, location_name: "Limit"))
    ListKeysRequest.add_member(:marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "Marker"))
    ListKeysRequest.struct_class = Types::ListKeysRequest

    ListKeysResponse.add_member(:keys, Shapes::ShapeRef.new(shape: KeyList, location_name: "Keys"))
    ListKeysResponse.add_member(:next_marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "NextMarker"))
    ListKeysResponse.add_member(:truncated, Shapes::ShapeRef.new(shape: BooleanType, location_name: "Truncated"))
    ListKeysResponse.struct_class = Types::ListKeysResponse

    ListResourceTagsRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    ListResourceTagsRequest.add_member(:limit, Shapes::ShapeRef.new(shape: LimitType, location_name: "Limit"))
    ListResourceTagsRequest.add_member(:marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "Marker"))
    ListResourceTagsRequest.struct_class = Types::ListResourceTagsRequest

    ListResourceTagsResponse.add_member(:tags, Shapes::ShapeRef.new(shape: TagList, location_name: "Tags"))
    ListResourceTagsResponse.add_member(:next_marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "NextMarker"))
    ListResourceTagsResponse.add_member(:truncated, Shapes::ShapeRef.new(shape: BooleanType, location_name: "Truncated"))
    ListResourceTagsResponse.struct_class = Types::ListResourceTagsResponse

    ListRetirableGrantsRequest.add_member(:limit, Shapes::ShapeRef.new(shape: LimitType, location_name: "Limit"))
    ListRetirableGrantsRequest.add_member(:marker, Shapes::ShapeRef.new(shape: MarkerType, location_name: "Marker"))
    ListRetirableGrantsRequest.add_member(:retiring_principal, Shapes::ShapeRef.new(shape: PrincipalIdType, required: true, location_name: "RetiringPrincipal"))
    ListRetirableGrantsRequest.struct_class = Types::ListRetirableGrantsRequest

    PolicyNameList.member = Shapes::ShapeRef.new(shape: PolicyNameType)

    PutKeyPolicyRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    PutKeyPolicyRequest.add_member(:policy_name, Shapes::ShapeRef.new(shape: PolicyNameType, required: true, location_name: "PolicyName"))
    PutKeyPolicyRequest.add_member(:policy, Shapes::ShapeRef.new(shape: PolicyType, required: true, location_name: "Policy"))
    PutKeyPolicyRequest.add_member(:bypass_policy_lockout_safety_check, Shapes::ShapeRef.new(shape: BooleanType, location_name: "BypassPolicyLockoutSafetyCheck"))
    PutKeyPolicyRequest.struct_class = Types::PutKeyPolicyRequest

    ReEncryptRequest.add_member(:ciphertext_blob, Shapes::ShapeRef.new(shape: CiphertextType, required: true, location_name: "CiphertextBlob"))
    ReEncryptRequest.add_member(:source_encryption_context, Shapes::ShapeRef.new(shape: EncryptionContextType, location_name: "SourceEncryptionContext"))
    ReEncryptRequest.add_member(:destination_key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "DestinationKeyId"))
    ReEncryptRequest.add_member(:destination_encryption_context, Shapes::ShapeRef.new(shape: EncryptionContextType, location_name: "DestinationEncryptionContext"))
    ReEncryptRequest.add_member(:grant_tokens, Shapes::ShapeRef.new(shape: GrantTokenList, location_name: "GrantTokens"))
    ReEncryptRequest.struct_class = Types::ReEncryptRequest

    ReEncryptResponse.add_member(:ciphertext_blob, Shapes::ShapeRef.new(shape: CiphertextType, location_name: "CiphertextBlob"))
    ReEncryptResponse.add_member(:source_key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "SourceKeyId"))
    ReEncryptResponse.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    ReEncryptResponse.struct_class = Types::ReEncryptResponse

    RetireGrantRequest.add_member(:grant_token, Shapes::ShapeRef.new(shape: GrantTokenType, location_name: "GrantToken"))
    RetireGrantRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    RetireGrantRequest.add_member(:grant_id, Shapes::ShapeRef.new(shape: GrantIdType, location_name: "GrantId"))
    RetireGrantRequest.struct_class = Types::RetireGrantRequest

    RevokeGrantRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    RevokeGrantRequest.add_member(:grant_id, Shapes::ShapeRef.new(shape: GrantIdType, required: true, location_name: "GrantId"))
    RevokeGrantRequest.struct_class = Types::RevokeGrantRequest

    ScheduleKeyDeletionRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    ScheduleKeyDeletionRequest.add_member(:pending_window_in_days, Shapes::ShapeRef.new(shape: PendingWindowInDaysType, location_name: "PendingWindowInDays"))
    ScheduleKeyDeletionRequest.struct_class = Types::ScheduleKeyDeletionRequest

    ScheduleKeyDeletionResponse.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, location_name: "KeyId"))
    ScheduleKeyDeletionResponse.add_member(:deletion_date, Shapes::ShapeRef.new(shape: DateType, location_name: "DeletionDate"))
    ScheduleKeyDeletionResponse.struct_class = Types::ScheduleKeyDeletionResponse

    Tag.add_member(:tag_key, Shapes::ShapeRef.new(shape: TagKeyType, required: true, location_name: "TagKey"))
    Tag.add_member(:tag_value, Shapes::ShapeRef.new(shape: TagValueType, required: true, location_name: "TagValue"))
    Tag.struct_class = Types::Tag

    TagKeyList.member = Shapes::ShapeRef.new(shape: TagKeyType)

    TagList.member = Shapes::ShapeRef.new(shape: Tag)

    TagResourceRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    TagResourceRequest.add_member(:tags, Shapes::ShapeRef.new(shape: TagList, required: true, location_name: "Tags"))
    TagResourceRequest.struct_class = Types::TagResourceRequest

    UntagResourceRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    UntagResourceRequest.add_member(:tag_keys, Shapes::ShapeRef.new(shape: TagKeyList, required: true, location_name: "TagKeys"))
    UntagResourceRequest.struct_class = Types::UntagResourceRequest

    UpdateAliasRequest.add_member(:alias_name, Shapes::ShapeRef.new(shape: AliasNameType, required: true, location_name: "AliasName"))
    UpdateAliasRequest.add_member(:target_key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "TargetKeyId"))
    UpdateAliasRequest.struct_class = Types::UpdateAliasRequest

    UpdateKeyDescriptionRequest.add_member(:key_id, Shapes::ShapeRef.new(shape: KeyIdType, required: true, location_name: "KeyId"))
    UpdateKeyDescriptionRequest.add_member(:description, Shapes::ShapeRef.new(shape: DescriptionType, required: true, location_name: "Description"))
    UpdateKeyDescriptionRequest.struct_class = Types::UpdateKeyDescriptionRequest


    # @api private
    API = Seahorse::Model::Api.new.tap do |api|

      api.version = "2014-11-01"

      api.metadata = {
        "endpointPrefix" => "kms",
        "jsonVersion" => "1.1",
        "protocol" => "json",
        "serviceFullName" => "AWS Key Management Service",
        "signatureVersion" => "v4",
        "targetPrefix" => "TrentService",
      }

      api.add_operation(:cancel_key_deletion, Seahorse::Model::Operation.new.tap do |o|
        o.name = "CancelKeyDeletion"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: CancelKeyDeletionRequest)
        o.output = Shapes::ShapeRef.new(shape: CancelKeyDeletionResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:create_alias, Seahorse::Model::Operation.new.tap do |o|
        o.name = "CreateAlias"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: CreateAliasRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: AlreadyExistsException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidAliasNameException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: LimitExceededException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:create_grant, Seahorse::Model::Operation.new.tap do |o|
        o.name = "CreateGrant"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: CreateGrantRequest)
        o.output = Shapes::ShapeRef.new(shape: CreateGrantResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DisabledException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidGrantTokenException)
        o.errors << Shapes::ShapeRef.new(shape: LimitExceededException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:create_key, Seahorse::Model::Operation.new.tap do |o|
        o.name = "CreateKey"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: CreateKeyRequest)
        o.output = Shapes::ShapeRef.new(shape: CreateKeyResponse)
        o.errors << Shapes::ShapeRef.new(shape: MalformedPolicyDocumentException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: UnsupportedOperationException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: LimitExceededException)
        o.errors << Shapes::ShapeRef.new(shape: TagException)
      end)

      api.add_operation(:decrypt, Seahorse::Model::Operation.new.tap do |o|
        o.name = "Decrypt"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: DecryptRequest)
        o.output = Shapes::ShapeRef.new(shape: DecryptResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DisabledException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidCiphertextException)
        o.errors << Shapes::ShapeRef.new(shape: KeyUnavailableException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidGrantTokenException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:delete_alias, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteAlias"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: DeleteAliasRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:delete_imported_key_material, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DeleteImportedKeyMaterial"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: DeleteImportedKeyMaterialRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: UnsupportedOperationException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:describe_key, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DescribeKey"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: DescribeKeyRequest)
        o.output = Shapes::ShapeRef.new(shape: DescribeKeyResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
      end)

      api.add_operation(:disable_key, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DisableKey"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: DisableKeyRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:disable_key_rotation, Seahorse::Model::Operation.new.tap do |o|
        o.name = "DisableKeyRotation"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: DisableKeyRotationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DisabledException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
        o.errors << Shapes::ShapeRef.new(shape: UnsupportedOperationException)
      end)

      api.add_operation(:enable_key, Seahorse::Model::Operation.new.tap do |o|
        o.name = "EnableKey"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: EnableKeyRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: LimitExceededException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:enable_key_rotation, Seahorse::Model::Operation.new.tap do |o|
        o.name = "EnableKeyRotation"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: EnableKeyRotationRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DisabledException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
        o.errors << Shapes::ShapeRef.new(shape: UnsupportedOperationException)
      end)

      api.add_operation(:encrypt, Seahorse::Model::Operation.new.tap do |o|
        o.name = "Encrypt"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: EncryptRequest)
        o.output = Shapes::ShapeRef.new(shape: EncryptResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DisabledException)
        o.errors << Shapes::ShapeRef.new(shape: KeyUnavailableException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidKeyUsageException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidGrantTokenException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:generate_data_key, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GenerateDataKey"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: GenerateDataKeyRequest)
        o.output = Shapes::ShapeRef.new(shape: GenerateDataKeyResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DisabledException)
        o.errors << Shapes::ShapeRef.new(shape: KeyUnavailableException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidKeyUsageException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidGrantTokenException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:generate_data_key_without_plaintext, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GenerateDataKeyWithoutPlaintext"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: GenerateDataKeyWithoutPlaintextRequest)
        o.output = Shapes::ShapeRef.new(shape: GenerateDataKeyWithoutPlaintextResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DisabledException)
        o.errors << Shapes::ShapeRef.new(shape: KeyUnavailableException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidKeyUsageException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidGrantTokenException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:generate_random, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GenerateRandom"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: GenerateRandomRequest)
        o.output = Shapes::ShapeRef.new(shape: GenerateRandomResponse)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
      end)

      api.add_operation(:get_key_policy, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetKeyPolicy"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: GetKeyPolicyRequest)
        o.output = Shapes::ShapeRef.new(shape: GetKeyPolicyResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:get_key_rotation_status, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetKeyRotationStatus"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: GetKeyRotationStatusRequest)
        o.output = Shapes::ShapeRef.new(shape: GetKeyRotationStatusResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
        o.errors << Shapes::ShapeRef.new(shape: UnsupportedOperationException)
      end)

      api.add_operation(:get_parameters_for_import, Seahorse::Model::Operation.new.tap do |o|
        o.name = "GetParametersForImport"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: GetParametersForImportRequest)
        o.output = Shapes::ShapeRef.new(shape: GetParametersForImportResponse)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: UnsupportedOperationException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:import_key_material, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ImportKeyMaterial"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: ImportKeyMaterialRequest)
        o.output = Shapes::ShapeRef.new(shape: ImportKeyMaterialResponse)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: UnsupportedOperationException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidCiphertextException)
        o.errors << Shapes::ShapeRef.new(shape: IncorrectKeyMaterialException)
        o.errors << Shapes::ShapeRef.new(shape: ExpiredImportTokenException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidImportTokenException)
      end)

      api.add_operation(:list_aliases, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListAliases"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: ListAliasesRequest)
        o.output = Shapes::ShapeRef.new(shape: ListAliasesResponse)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidMarkerException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o[:pager] = Aws::Pager.new(
          more_results: "truncated",
          limit_key: "limit",
          tokens: {
            "next_marker" => "marker"
          }
        )
      end)

      api.add_operation(:list_grants, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListGrants"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: ListGrantsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListGrantsResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidMarkerException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
        o[:pager] = Aws::Pager.new(
          more_results: "truncated",
          limit_key: "limit",
          tokens: {
            "next_marker" => "marker"
          }
        )
      end)

      api.add_operation(:list_key_policies, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListKeyPolicies"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: ListKeyPoliciesRequest)
        o.output = Shapes::ShapeRef.new(shape: ListKeyPoliciesResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
        o[:pager] = Aws::Pager.new(
          more_results: "truncated",
          limit_key: "limit",
          tokens: {
            "next_marker" => "marker"
          }
        )
      end)

      api.add_operation(:list_keys, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListKeys"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: ListKeysRequest)
        o.output = Shapes::ShapeRef.new(shape: ListKeysResponse)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidMarkerException)
        o[:pager] = Aws::Pager.new(
          more_results: "truncated",
          limit_key: "limit",
          tokens: {
            "next_marker" => "marker"
          }
        )
      end)

      api.add_operation(:list_resource_tags, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListResourceTags"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: ListResourceTagsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListResourceTagsResponse)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidMarkerException)
      end)

      api.add_operation(:list_retirable_grants, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ListRetirableGrants"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: ListRetirableGrantsRequest)
        o.output = Shapes::ShapeRef.new(shape: ListGrantsResponse)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidMarkerException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
      end)

      api.add_operation(:put_key_policy, Seahorse::Model::Operation.new.tap do |o|
        o.name = "PutKeyPolicy"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: PutKeyPolicyRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: MalformedPolicyDocumentException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: UnsupportedOperationException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: LimitExceededException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:re_encrypt, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ReEncrypt"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: ReEncryptRequest)
        o.output = Shapes::ShapeRef.new(shape: ReEncryptResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DisabledException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidCiphertextException)
        o.errors << Shapes::ShapeRef.new(shape: KeyUnavailableException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidKeyUsageException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidGrantTokenException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:retire_grant, Seahorse::Model::Operation.new.tap do |o|
        o.name = "RetireGrant"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: RetireGrantRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidGrantTokenException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidGrantIdException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:revoke_grant, Seahorse::Model::Operation.new.tap do |o|
        o.name = "RevokeGrant"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: RevokeGrantRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidGrantIdException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:schedule_key_deletion, Seahorse::Model::Operation.new.tap do |o|
        o.name = "ScheduleKeyDeletion"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: ScheduleKeyDeletionRequest)
        o.output = Shapes::ShapeRef.new(shape: ScheduleKeyDeletionResponse)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:tag_resource, Seahorse::Model::Operation.new.tap do |o|
        o.name = "TagResource"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: TagResourceRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
        o.errors << Shapes::ShapeRef.new(shape: LimitExceededException)
        o.errors << Shapes::ShapeRef.new(shape: TagException)
      end)

      api.add_operation(:untag_resource, Seahorse::Model::Operation.new.tap do |o|
        o.name = "UntagResource"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: UntagResourceRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
        o.errors << Shapes::ShapeRef.new(shape: TagException)
      end)

      api.add_operation(:update_alias, Seahorse::Model::Operation.new.tap do |o|
        o.name = "UpdateAlias"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: UpdateAliasRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)

      api.add_operation(:update_key_description, Seahorse::Model::Operation.new.tap do |o|
        o.name = "UpdateKeyDescription"
        o.http_method = "POST"
        o.http_request_uri = "/"
        o.input = Shapes::ShapeRef.new(shape: UpdateKeyDescriptionRequest)
        o.output = Shapes::ShapeRef.new(shape: Shapes::StructureShape.new(struct_class: Aws::EmptyStructure))
        o.errors << Shapes::ShapeRef.new(shape: NotFoundException)
        o.errors << Shapes::ShapeRef.new(shape: InvalidArnException)
        o.errors << Shapes::ShapeRef.new(shape: DependencyTimeoutException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInternalException)
        o.errors << Shapes::ShapeRef.new(shape: KMSInvalidStateException)
      end)
    end

  end
end
