# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::UndoBlockSerializer do
  subject { serialized_record_json(block, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:block) { Fabricate(:block) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(block.account)}#blocks/#{block.id}/undo",
      'type' => 'Undo',
      'actor' => tag_manager.uri_for(block.account),
      'object' => a_hash_including({
        'type' => 'Block',
      }),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end
end
