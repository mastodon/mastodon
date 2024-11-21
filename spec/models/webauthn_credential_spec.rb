# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebauthnCredential do
  describe 'Validations' do
    subject { Fabricate.build :webauthn_credential }

    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:public_key) }
    it { is_expected.to validate_presence_of(:nickname) }
    it { is_expected.to validate_presence_of(:sign_count) }

    it { is_expected.to validate_uniqueness_of(:external_id) }
    it { is_expected.to validate_uniqueness_of(:nickname).scoped_to(:user_id) }

    it { is_expected.to validate_numericality_of(:sign_count).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(described_class::SIGN_COUNT_LIMIT - 1) }
  end
end
