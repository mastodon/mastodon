# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ActorSerializer do
  subject { serialized_record_json(record, described_class, adapter: ActivityPub::Adapter) }

  describe '#type' do
    context 'with the instance actor' do
      let(:record) { Account.find(Account::INSTANCE_ACTOR_ID) }

      it { is_expected.to include('type' => 'Application') }
    end

    context 'with an application actor' do
      let(:record) { Fabricate :account, actor_type: 'Application' }

      it { is_expected.to include('type' => 'Service') }
    end

    context 'with a service actor' do
      let(:record) { Fabricate :account, actor_type: 'Service' }

      it { is_expected.to include('type' => 'Service') }
    end

    context 'with a Group actor' do
      let(:record) { Fabricate :account, actor_type: 'Group' }

      it { is_expected.to include('type' => 'Group') }
    end

    context 'with a Person actor' do
      let(:record) { Fabricate :account, actor_type: 'Person' }

      it { is_expected.to include('type' => 'Person') }
    end
  end

  describe '#interactionPolicy' do
    let(:record) { Fabricate(:account) }

    # TODO: Remove when feature flag is removed
    context 'when collections feature is disabled?' do
      it 'is not present' do
        expect(subject).to_not have_key('interactionPolicy')
      end
    end

    context 'when collections feature is enabled', feature: :collections do
      context 'when actor is discoverable' do
        it 'includes an automatic policy allowing everyone' do
          expect(subject).to include('interactionPolicy' => {
            'canFeature' => {
              'automaticApproval' => ['https://www.w3.org/ns/activitystreams#Public'],
            },
          })
        end
      end

      context 'when actor is not discoverable' do
        let(:record) { Fabricate(:account, discoverable: false) }

        it 'includes an automatic policy limited to the actor itself' do
          expect(subject).to include('interactionPolicy' => {
            'canFeature' => {
              'automaticApproval' => [ActivityPub::TagManager.instance.uri_for(record)],
            },
          })
        end
      end
    end
  end
end
