require 'spec_helper'
require 'active_support/core_ext/object/blank'
require 'doorkeeper/models/concerns/revocable'

describe 'Revocable' do
  subject do
    Class.new do
      include Doorkeeper::Models::Revocable
    end.new
  end

  describe :revoke do
    it 'updates :revoked_at attribute with current time' do
      utc = double utc: double
      clock = double now: utc
      expect(subject).to receive(:update_attribute).with(:revoked_at, clock.now.utc)
      subject.revoke(clock)
    end
  end

  describe :revoked? do
    it 'is revoked if :revoked_at has passed' do
      allow(subject).to receive(:revoked_at).and_return(Time.now.utc - 1000)
      expect(subject).to be_revoked
    end

    it 'is not revoked if :revoked_at has not passed' do
      allow(subject).to receive(:revoked_at).and_return(Time.now.utc + 1000)
      expect(subject).not_to be_revoked
    end

    it 'is not revoked if :revoked_at is not set' do
      allow(subject).to receive(:revoked_at).and_return(nil)
      expect(subject).not_to be_revoked
    end
  end

  describe :revoke_previous_refresh_token! do
    it "revokes the previous token if existing, and resets the
      `previous_refresh_token` attribute" do
      previous_token = FactoryBot.create(
        :access_token,
        refresh_token: "refresh_token"
      )
      current_token = FactoryBot.create(
        :access_token,
        previous_refresh_token: previous_token.refresh_token
      )

      expect_any_instance_of(
        Doorkeeper::AccessToken
      ).to receive(:revoke).and_call_original
      current_token.revoke_previous_refresh_token!

      expect(current_token.previous_refresh_token).to be_empty
      expect(previous_token.reload).to be_revoked
    end
  end
end
