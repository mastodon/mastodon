require 'rails_helper'

RSpec.describe WebauthnCredential, type: :model do
  describe 'validations' do
    it 'is invalid without an external id' do
      webauthn_credential = Fabricate.build(:webauthn_credential, external_id: nil)

      webauthn_credential.valid?

      expect(webauthn_credential).to model_have_error_on_field(:external_id)
    end

    it 'is invalid without a public key' do
      webauthn_credential = Fabricate.build(:webauthn_credential, public_key: nil)

      webauthn_credential.valid?

      expect(webauthn_credential).to model_have_error_on_field(:public_key)
    end

    it 'is invalid without a nickname' do
      webauthn_credential = Fabricate.build(:webauthn_credential, nickname: nil)

      webauthn_credential.valid?

      expect(webauthn_credential).to model_have_error_on_field(:nickname)
    end

    it 'is invalid without a sign_count' do
      webauthn_credential = Fabricate.build(:webauthn_credential, sign_count: nil)

      webauthn_credential.valid?

      expect(webauthn_credential).to model_have_error_on_field(:sign_count)
    end

    it 'is invalid if already exist a webauthn credential with the same external id' do
      existing_webauthn_credential = Fabricate(:webauthn_credential, external_id: '_Typ0ygudDnk9YUVWLQayw')
      new_webauthn_credential = Fabricate.build(:webauthn_credential, external_id: '_Typ0ygudDnk9YUVWLQayw')

      new_webauthn_credential.valid?

      expect(new_webauthn_credential).to model_have_error_on_field(:external_id)
    end

    it 'is invalid if user already registered a webauthn credential with the same nickname' do
      user = Fabricate(:user)
      existing_webauthn_credential = Fabricate(:webauthn_credential, user_id: user.id, nickname: 'USB Key')
      new_webauthn_credential = Fabricate.build(:webauthn_credential, user_id: user.id, nickname: 'USB Key')

      new_webauthn_credential.valid?

      expect(new_webauthn_credential).to model_have_error_on_field(:nickname)
    end

    it 'is invalid if sign_count is not a number' do
      webauthn_credential = Fabricate.build(:webauthn_credential, sign_count: 'invalid sign_count')

      webauthn_credential.valid?

      expect(webauthn_credential).to model_have_error_on_field(:sign_count)
    end

    it 'is invalid if sign_count is negative number' do
      webauthn_credential = Fabricate.build(:webauthn_credential, sign_count: -1)

      webauthn_credential.valid?

      expect(webauthn_credential).to model_have_error_on_field(:sign_count)
    end

    it 'is invalid if sign_count is greater 2**63 - 1' do
      webauthn_credential = Fabricate.build(:webauthn_credential, sign_count: 2**63)

      webauthn_credential.valid?

      expect(webauthn_credential).to model_have_error_on_field(:sign_count)
    end
  end
end
