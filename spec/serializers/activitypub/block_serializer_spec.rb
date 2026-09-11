# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::BlockSerializer do
  subject { serialized_record_json(block, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:block) { Fabricate(:block, uri: 'https://localhost/block/1') }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => 'https://localhost/block/1',
      'type' => 'Block',
      'actor' => tag_manager.uri_for(block.account),
      'object' => tag_manager.uri_for(block.target_account),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
