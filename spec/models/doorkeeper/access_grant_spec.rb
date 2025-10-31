# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doorkeeper::AccessGrant do
  describe 'Validations' do
    subject { Fabricate :access_grant }

    it { is_expected.to validate_presence_of(:application_id) }
    it { is_expected.to validate_presence_of(:expires_in) }
    it { is_expected.to validate_presence_of(:redirect_uri) }
    it { is_expected.to validate_presence_of(:token) }
  end

  describe 'Scopes' do
    describe '.expired' do
      let!(:unexpired) { Fabricate :access_grant, expires_in: 10.hours }
      let!(:expired) do
        travel_to 10.minutes.ago do
          Fabricate :access_grant, expires_in: 5.minutes
        end
      end

      it 'returns records past their expired time' do
        expect(described_class.expired)
          .to include(expired)
          .and not_include(unexpired)
      end
    end

    describe '.revoked' do
      let!(:revoked) { Fabricate :access_grant, revoked_at: 10.minutes.ago }
      let!(:unrevoked) { Fabricate :access_grant, revoked_at: 10.minutes.from_now }

      it 'returns records past their expired time' do
        expect(described_class.revoked)
          .to include(revoked)
          .and not_include(unrevoked)
      end
    end
  end
end
