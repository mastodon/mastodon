# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::RejectFollowSerializer do
  subject { serialized_record_json(record, described_class, adapter: ActivityPub::Adapter) }

  describe 'serializing an object' do
    let(:record) { Fabricate :follow_request }

    it 'returns expected attributes' do
      expect(subject.deep_symbolize_keys)
        .to include(
          actor: eq(ActivityPub::TagManager.instance.uri_for(record.target_account)),
          id: match("#rejects/follows/#{record.id}"),
          object: include(type: 'Follow'),
          type: 'Reject'
        )
    end
  end
end
