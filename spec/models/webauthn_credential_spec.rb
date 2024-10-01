# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebauthnCredential do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:public_key) }
    it { is_expected.to validate_presence_of(:nickname) }
    it { is_expected.to validate_presence_of(:sign_count) }

    it 'is invalid if already exist a webauthn credential with the same external id' do
      Fabricate(:webauthn_credential, external_id: '_Typ0ygudDnk9YUVWLQayw')
      new_webauthn_credential = Fabricate.build(:webauthn_credential, external_id: '_Typ0ygudDnk9YUVWLQayw')

      new_webauthn_credential.valid?

      expect(new_webauthn_credential).to model_have_error_on_field(:external_id)
    end

    it 'is invalid if user already registered a webauthn credential with the same nickname' do
      user = Fabricate(:user)
      Fabricate(:webauthn_credential, user_id: user.id, nickname: 'USB Key')
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

    it 'is invalid if sign_count is greater than the limit' do
      webauthn_credential = Fabricate.build(:webauthn_credential, sign_count: (described_class::SIGN_COUNT_LIMIT * 2))

      webauthn_credential.valid?

      expect(webauthn_credential).to model_have_error_on_field(:sign_count)
    end
  end
end
