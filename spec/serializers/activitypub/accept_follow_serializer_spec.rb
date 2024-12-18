# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::AcceptFollowSerializer do
  subject { serialized_record_json(record, described_class, adapter: ActivityPub::Adapter) }

  describe 'serializing an object' do
    let(:record) { Fabricate :follow_request }

    it 'returns expected attributes' do
      expect(subject.deep_symbolize_keys)
        .to include(
          actor: match(record.target_account.username),
          id: match("#accepts/follows/#{record.id}"),
          object: include(type: 'Follow'),
          type: 'Accept'
        )
    end
  end
end
