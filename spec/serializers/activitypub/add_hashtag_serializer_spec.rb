# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::AddHashtagSerializer do
  subject { serialized_record_json(object, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:object) { Fabricate(:featured_tag) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'type' => 'Add',
      'actor' => tag_manager.uri_for(object.account),
      'target' => a_string_matching(%r{/featured$}),
      'object' => a_hash_including({
        'type' => 'Hashtag',
      }),
    })

    expect(subject).to_not have_key('id')
    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
  end
end
