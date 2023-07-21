# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification do
  describe '#target_status' do
    let(:notification) { Fabricate(:notification, activity: activity) }
    let(:status)       { Fabricate(:status) }
    let(:reblog)       { Fabricate(:status, reblog: status) }
    let(:favourite)    { Fabricate(:favourite, status: status) }
    let(:mention)      { Fabricate(:mention, status: status) }

    context 'when Activity is reblog' do
      let(:activity) { reblog }

      it 'returns status' do
        expect(notification.target_status).to eq status
      end
    end

    context 'when Activity is favourite' do
      let(:type)     { :favourite }
      let(:activity) { favourite }

      it 'returns status' do
        expect(notification.target_status).to eq status
      end
    end

    context 'when Activity is mention' do
      let(:activity) { mention }

      it 'returns status' do
        expect(notification.target_status).to eq status
      end
    end
  end

  describe '#type' do
    it 'returns :reblog for a Status' do
      notification = described_class.new(activity: Status.new)
      expect(notification.type).to eq :reblog
    end

    it 'returns :mention for a Mention' do
      notification = described_class.new(activity: Mention.new)
      expect(notification.type).to eq :mention
    end

    it 'returns :favourite for a Favourite' do
      notification = described_class.new(activity: Favourite.new)
      expect(notification.type).to eq :favourite
    end

    it 'returns :follow for a Follow' do
      notification = described_class.new(activity: Follow.new)
      expect(notification.type).to eq :follow
    end
  end

  describe '.preload_cache_collection_target_statuses' do
    subject do
      described_class.preload_cache_collection_target_statuses(notifications) do |target_statuses|
        # preload account for testing instead of using cache_collection
        Status.preload(:account).where(id: target_statuses.map(&:id))
      end
    end

    context 'when notifications are empty' do
      let(:notifications) { [] }

      it 'returns []' do
        expect(subject).to eq []
      end
    end

    context 'when notifications are present' do
      before do
        notifications.each(&:reload)
      end

      let(:mention) { Fabricate(:mention) }
      let(:status) { Fabricate(:status) }
      let(:reblog) { Fabricate(:status, reblog: Fabricate(:status)) }
      let(:follow) { Fabricate(:follow) }
      let(:follow_request) { Fabricate(:follow_request) }
      let(:favourite) { Fabricate(:favourite) }
      let(:poll) { Fabricate(:poll) }

      let(:notifications) do
        [
          Fabricate(:notification, type: :mention, activity: mention),
          Fabricate(:notification, type: :status, activity: status),
          Fabricate(:notification, type: :reblog, activity: reblog),
          Fabricate(:notification, type: :follow, activity: follow),
          Fabricate(:notification, type: :follow_request, activity: follow_request),
          Fabricate(:notification, type: :favourite, activity: favourite),
          Fabricate(:notification, type: :poll, activity: poll),
        ]
      end

      context 'with a preloaded target status' do
        it 'preloads mention' do
          expect(subject[0].type).to eq :mention
          expect(subject[0].association(:mention)).to be_loaded
          expect(subject[0].mention.association(:status)).to be_loaded
        end

        it 'preloads status' do
          expect(subject[1].type).to eq :status
          expect(subject[1].association(:status)).to be_loaded
        end

        it 'preloads reblog' do
          expect(subject[2].type).to eq :reblog
          expect(subject[2].association(:status)).to be_loaded
          expect(subject[2].status.association(:reblog)).to be_loaded
        end

        it 'preloads follow as nil' do
          expect(subject[3].type).to eq :follow
          expect(subject[3].target_status).to be_nil
        end

        it 'preloads follow_request as nill' do
          expect(subject[4].type).to eq :follow_request
          expect(subject[4].target_status).to be_nil
        end

        it 'preloads favourite' do
          expect(subject[5].type).to eq :favourite
          expect(subject[5].association(:favourite)).to be_loaded
          expect(subject[5].favourite.association(:status)).to be_loaded
        end

        it 'preloads poll' do
          expect(subject[6].type).to eq :poll
          expect(subject[6].association(:poll)).to be_loaded
          expect(subject[6].poll.association(:status)).to be_loaded
        end
      end

      context 'with a cached status' do
        it 'replaces mention' do
          expect(subject[0].type).to eq :mention
          expect(subject[0].target_status.association(:account)).to be_loaded
          expect(subject[0].target_status).to eq mention.status
        end

        it 'replaces status' do
          expect(subject[1].type).to eq :status
          expect(subject[1].target_status.association(:account)).to be_loaded
          expect(subject[1].target_status).to eq status
        end

        it 'replaces reblog' do
          expect(subject[2].type).to eq :reblog
          expect(subject[2].target_status.association(:account)).to be_loaded
          expect(subject[2].target_status).to eq reblog.reblog
        end

        it 'replaces follow' do
          expect(subject[3].type).to eq :follow
          expect(subject[3].target_status).to be_nil
        end

        it 'replaces follow_request' do
          expect(subject[4].type).to eq :follow_request
          expect(subject[4].target_status).to be_nil
        end

        it 'replaces favourite' do
          expect(subject[5].type).to eq :favourite
          expect(subject[5].target_status.association(:account)).to be_loaded
          expect(subject[5].target_status).to eq favourite.status
        end

        it 'replaces poll' do
          expect(subject[6].type).to eq :poll
          expect(subject[6].target_status.association(:account)).to be_loaded
          expect(subject[6].target_status).to eq poll.status
        end
      end
    end
  end
end
