# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacuum::AccessTokensVacuum do
  subject { described_class.new }

  describe '#perform' do
    let!(:revoked_access_token) { Fabricate(:access_token, revoked_at: 1.minute.ago) }
    let!(:expired_access_token) { Fabricate(:access_token, expires_in: 59.minutes.to_i, created_at: 1.hour.ago) }
    let!(:active_access_token) { Fabricate(:access_token) }

    let!(:revoked_access_grant) { Fabricate(:access_grant, revoked_at: 1.minute.ago) }
    let!(:expired_access_grant) { Fabricate(:access_grant, expires_in: 59.minutes.to_i, created_at: 1.hour.ago) }
    let!(:active_access_grant) { Fabricate(:access_grant) }

    it 'deletes revoked/expired access tokens and revoked/expired grants, but preserves active tokens/grants' do
      subject.perform

      expect { revoked_access_token.reload }
        .to raise_error ActiveRecord::RecordNotFound
      expect { expired_access_token.reload }
        .to raise_error ActiveRecord::RecordNotFound

      expect { revoked_access_grant.reload }
        .to raise_error ActiveRecord::RecordNotFound
      expect { expired_access_grant.reload }
        .to raise_error ActiveRecord::RecordNotFound

      expect { active_access_token.reload }
        .to_not raise_error

      expect { active_access_grant.reload }
        .to_not raise_error
    end
  end
end
