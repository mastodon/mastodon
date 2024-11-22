# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::StatusSerializer do
  subject do
    serialized_record_json(
      status,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob', domain: 'other.com') }
  let(:status) { Fabricate(:status, account: alice) }

  context 'with a remote status' do
    let(:status) { Fabricate(:status, account: bob) }

    before do
      status.status_stat.tap do |status_stat|
        status_stat.reblogs_count = 10
        status_stat.favourites_count = 20
        status_stat.save
      end
    end

    context 'with only trusted counts' do
      it 'shows the trusted counts' do
        expect(subject['reblogs_count']).to eq(10)
        expect(subject['favourites_count']).to eq(20)
      end
    end

    context 'with untrusted counts' do
      before do
        status.status_stat.tap do |status_stat|
          status_stat.untrusted_reblogs_count = 30
          status_stat.untrusted_favourites_count = 40
          status_stat.save
        end
      end

      it 'shows the untrusted counts' do
        expect(subject['reblogs_count']).to eq(30)
        expect(subject['favourites_count']).to eq(40)
      end
    end
  end
end
