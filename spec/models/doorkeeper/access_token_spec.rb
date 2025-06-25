# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doorkeeper::AccessToken do
  describe 'Associations' do
    it { is_expected.to have_many(:web_push_subscriptions).class_name('Web::PushSubscription').inverse_of(:access_token) }
  end

  describe 'Validations' do
    subject { Fabricate :access_token }

    it { is_expected.to validate_presence_of(:token) }
  end

  describe 'Scopes' do
    describe '.expired' do
      let!(:unexpired) { Fabricate :access_token, expires_in: 10.hours }
      let!(:expired) do
        travel_to 10.minutes.ago do
          Fabricate :access_token, expires_in: 5.minutes
        end
      end

      it 'returns records past their expired time' do
        expect(described_class.expired)
          .to include(expired)
          .and not_include(unexpired)
      end
    end

    describe '.revoked' do
      let!(:revoked) { Fabricate :access_token, revoked_at: 10.minutes.ago }
      let!(:unrevoked) { Fabricate :access_token, revoked_at: 10.minutes.from_now }

      it 'returns records past their expired time' do
        expect(described_class.revoked)
          .to include(revoked)
          .and not_include(unrevoked)
      end
    end
  end

  describe '#revoke' do
    let(:record) { Fabricate :access_token, revoked_at: 10.days.from_now }

    it 'marks the record as revoked' do
      expect { record.revoke }
        .to change(record, :revoked_at).to(be_within(1).of(Time.now.utc))
    end
  end

  describe '#update_last_used' do
    let(:record) { Fabricate :access_token, last_used_at: nil, last_used_ip: nil }
    let(:request) { instance_double(ActionDispatch::Request, remote_ip: '1.1.1.1') }

    it 'marks the record as revoked' do
      expect { record.update_last_used(request) }
        .to change(record, :last_used_at).to(be_within(1).of(Time.now.utc))
        .and change(record, :last_used_ip).to(IPAddr.new('1.1.1.1'))
    end
  end
end
