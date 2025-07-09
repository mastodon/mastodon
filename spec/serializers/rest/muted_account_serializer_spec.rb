# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::MutedAccountSerializer do
  subject do
    serialized_record_json(
      mutee,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:account) { current_user.account }
  let(:mutee) { Fabricate(:account, username: 'mutee') }

  context 'when mute_expires_at is populated and non-nil' do
    before do
      account.follow!(mutee)
      account.mute!(mutee, duration: 1.day)
    end

    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'mute_expires_at' => match_api_datetime_format
        )
    end
  end

  context 'when mute has no duration' do
    before do
      account.follow!(mutee)
      account.mute!(mutee)
    end

    it 'has a nil mute_expires_at' do
      expect(subject['mute_expires_at']).to be_nil
    end
  end
end
