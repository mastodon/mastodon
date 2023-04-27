# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacuum::AccessTokensVacuum do
  subject { described_class.new }

  describe '#perform' do
    let!(:revoked_access_token) { Fabricate(:access_token, revoked_at: 1.minute.ago) }
    let!(:active_access_token) { Fabricate(:access_token) }

    let!(:revoked_access_grant) { Fabricate(:access_grant, revoked_at: 1.minute.ago) }
    let!(:active_access_grant) { Fabricate(:access_grant) }

    before do
      subject.perform
    end

    it 'deletes revoked access tokens' do
      expect { revoked_access_token.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes revoked access grants' do
      expect { revoked_access_grant.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'does not delete active access tokens' do
      expect { active_access_token.reload }.to_not raise_error
    end

    it 'does not delete active access grants' do
      expect { active_access_grant.reload }.to_not raise_error
    end
  end
end
