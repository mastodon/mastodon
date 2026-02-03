# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ActivitySerializer do
  subject { serialized_record_json(presenter, described_class, adapter: ActivityPub::Adapter) }

  let(:tag_manager) { ActivityPub::TagManager.instance }
  let(:status) { Fabricate(:status, created_at: Time.utc(2026, 0o1, 27, 15, 29, 31)) }

  context 'with a new status' do
    let(:presenter) { ActivityPub::ActivityPresenter.from_status(status) }

    it 'serializes to the expected json' do
      expect(subject).to include({
        'id' => tag_manager.activity_uri_for(status),
        'type' => 'Create',
        'actor' => tag_manager.uri_for(status.account),
        'published' => '2026-01-27T15:29:31Z',
        'to' => ['https://www.w3.org/ns/activitystreams#Public'],
        'cc' => [a_string_matching(/followers$/)],
        'object' => a_hash_including(
          'id' => tag_manager.uri_for(status)
        ),
      })

      expect(subject).to_not have_key('target')
    end
  end

  context 'with a new reblog' do
    let(:reblog) { Fabricate(:status, reblog: status, created_at: Time.utc(2026, 0o1, 27, 16, 21, 44)) }
    let(:presenter) { ActivityPub::ActivityPresenter.from_status(reblog) }

    it 'serializes to the expected json' do
      expect(subject).to include({
        'id' => tag_manager.activity_uri_for(reblog),
        'type' => 'Announce',
        'actor' => tag_manager.uri_for(reblog.account),
        'published' => '2026-01-27T16:21:44Z',
        'to' => ['https://www.w3.org/ns/activitystreams#Public'],
        'cc' => [tag_manager.uri_for(status.account), a_string_matching(/followers$/)],
        'object' => tag_manager.uri_for(status),
      })

      expect(subject).to_not have_key('target')
    end

    context 'when inlining of private local status is allowed' do
      let(:status) { Fabricate(:status, visibility: :private, created_at: Time.utc(2026, 0o1, 27, 15, 29, 31)) }
      let(:reblog) { Fabricate(:status, reblog: status, account: status.account, created_at: Time.utc(2026, 0o1, 27, 16, 21, 44)) }
      let(:presenter) { ActivityPub::ActivityPresenter.from_status(reblog, allow_inlining: true) }

      it 'serializes to the expected json' do
        expect(subject).to include({
          'id' => tag_manager.activity_uri_for(reblog),
          'type' => 'Announce',
          'actor' => tag_manager.uri_for(reblog.account),
          'published' => '2026-01-27T16:21:44Z',
          'to' => ['https://www.w3.org/ns/activitystreams#Public'],
          'cc' => [tag_manager.uri_for(status.account), a_string_matching(/followers$/)],
          'object' => a_hash_including(
            'id' => tag_manager.uri_for(status)
          ),
        })

        expect(subject).to_not have_key('target')
      end
    end
  end

  context 'with a custom presenter for a status `Update`' do
    let(:status) { Fabricate(:status, edited_at: Time.utc(2026, 0o1, 27, 15, 29, 31)) }
    let(:presenter) do
      ActivityPub::ActivityPresenter.new(
        id: 'https://localhost/status/1#updates/1769527771',
        type: 'Update',
        actor: 'https://localhost/actor/1',
        published: status.edited_at,
        to: ['https://www.w3.org/ns/activitystreams#Public'],
        cc: ['https://localhost/actor/1/followers'],
        virtual_object: status
      )
    end

    it 'serializes to the expected json' do
      expect(subject).to include({
        'id' => 'https://localhost/status/1#updates/1769527771',
        'type' => 'Update',
        'actor' => 'https://localhost/actor/1',
        'published' => '2026-01-27T15:29:31Z',
        'to' => ['https://www.w3.org/ns/activitystreams#Public'],
        'cc' => ['https://localhost/actor/1/followers'],
        'object' => a_hash_including(
          'id' => tag_manager.uri_for(status)
        ),
      })

      expect(subject).to_not have_key('target')
    end
  end
end
