# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::MoveSerializer do
  subject { serialized_record_json(account_migration, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:account_migration) { Fabricate(:account_migration) }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => "#{tag_manager.uri_for(account_migration.account)}#moves/#{account_migration.id}",
      'type' => 'Move',
      'actor' => tag_manager.uri_for(account_migration.account),
      'target' => tag_manager.uri_for(account_migration.target_account),
      'object' => tag_manager.uri_for(account_migration.account),
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
  end
end
