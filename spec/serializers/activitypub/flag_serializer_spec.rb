# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FlagSerializer do
  subject { serialized_record_json(report, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:report) { Fabricate(:report, comment: 'good reason') }

  it 'serializes to the expected json' do
    expect(subject).to include({
      'id' => tag_manager.uri_for(report),
      'type' => 'Flag',
      'actor' => tag_manager.uri_for(report.account),
      'content' => 'good reason',
      'object' => [tag_manager.uri_for(report.target_account)],
    })

    expect(subject).to_not have_key('published')
    expect(subject).to_not have_key('to')
    expect(subject).to_not have_key('cc')
    expect(subject).to_not have_key('target')
  end

  context 'with status' do
    let(:target_account) { Fabricate(:account) }
    let(:status) { Fabricate(:status, account: target_account) }
    let(:report) { Fabricate(:report, target_account:, status_ids: [status.id]) }

    it 'includes the status URI in `object`' do
      expect(subject).to include({
        'object' => [
          tag_manager.uri_for(target_account),
          tag_manager.uri_for(status),
        ],
      })
    end
  end

  context 'with collection', feature: :collections do
    let(:target_account) { Fabricate(:account) }
    let(:collection) { Fabricate(:collection, account: target_account) }
    let(:report) { Fabricate(:report, target_account:, collections: [collection]) }

    it 'includes the collection URI in `object`' do
      expect(subject).to include({
        'object' => [
          tag_manager.uri_for(target_account),
          tag_manager.uri_for(collection),
        ],
      })
    end
  end
end
