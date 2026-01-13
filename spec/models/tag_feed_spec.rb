# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagFeed do
  describe '#get' do
    let(:account) { Fabricate(:account) }
    let(:tag_cats) { Fabricate(:tag, name: 'cats') }
    let(:tag_dogs) { Fabricate(:tag, name: 'dogs') }
    let!(:status_tagged_with_cats) { Fabricate(:status, tags: [tag_cats]) }
    let!(:status_tagged_with_dogs) { Fabricate(:status, tags: [tag_dogs]) }
    let!(:both) { Fabricate(:status, tags: [tag_cats, tag_dogs]) }

    it 'can add tags in "any" mode' do
      results = described_class.new(tag_cats, nil, any: [tag_dogs.name]).get(20)
      expect(results).to include status_tagged_with_cats
      expect(results).to include status_tagged_with_dogs
      expect(results).to include both
    end

    it 'can remove tags in "all" mode' do
      results = described_class.new(tag_cats, nil, all: [tag_dogs.name]).get(20)
      expect(results).to_not include status_tagged_with_cats
      expect(results).to_not include status_tagged_with_dogs
      expect(results).to     include both
    end

    it 'can remove tags in "none" mode' do
      results = described_class.new(tag_cats, nil, none: [tag_dogs.name]).get(20)
      expect(results).to     include status_tagged_with_cats
      expect(results).to_not include status_tagged_with_dogs
      expect(results).to_not include both
    end

    it 'ignores an invalid mode' do
      results = described_class.new(tag_cats, nil, wark: [tag_dogs.name]).get(20)
      expect(results).to     include status_tagged_with_cats
      expect(results).to_not include status_tagged_with_dogs
      expect(results).to     include both
    end

    it 'handles being passed non existent tag names' do
      results = described_class.new(tag_cats, nil, any: ['wark']).get(20)
      expect(results).to     include status_tagged_with_cats
      expect(results).to_not include status_tagged_with_dogs
      expect(results).to     include both
    end

    it 'can restrict to an account' do
      BlockService.new.call(account, status_tagged_with_cats.account)
      results = described_class.new(tag_cats, account, none: [tag_dogs.name]).get(20)
      expect(results).to_not include status_tagged_with_cats
    end

    it 'can restrict to local' do
      status_tagged_with_cats.account.update(domain: 'example.com')
      status_tagged_with_cats.update(local: false, uri: 'example.com/toot')
      results = described_class.new(tag_cats, nil, any: [tag_dogs.name], local: true).get(20)
      expect(results).to_not include status_tagged_with_cats
    end

    it 'allows replies to be included' do
      original = Fabricate(:status)
      status = Fabricate(:status, tags: [tag_cats], in_reply_to_id: original.id)

      results = described_class.new(tag_cats, nil).get(20)
      expect(results).to include(status)
    end

    context 'when both local_topic_feed_access and remote_topic_feed_access are disabled' do
      before do
        Setting.local_topic_feed_access = 'disabled'
        Setting.remote_topic_feed_access = 'disabled'
      end

      context 'without local_only option' do
        subject { described_class.new(tag_cats, viewer).get(20).map(&:id) }

        let(:viewer) { nil }

        let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
        let!(:local_status)   { status_tagged_with_cats }
        let!(:remote_status)  { Fabricate(:status, account: remote_account, tags: [tag_cats]) }

        context 'without a viewer' do
          let(:viewer) { nil }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a viewer' do
          let(:viewer) { Fabricate(:account, username: 'viewer') }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a moderator as viewer' do
          let(:viewer) { Fabricate(:moderator_user).account }

          it 'includes all expected statuses' do
            expect(subject).to include(local_status.id)
            expect(subject).to include(remote_status.id)
          end
        end
      end

      context 'with a local_only option set' do
        subject { described_class.new(tag_cats, viewer, local: true).get(20).map(&:id) }

        let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
        let!(:local_status)   { status_tagged_with_cats }
        let!(:remote_status)  { Fabricate(:status, account: remote_account, tags: [tag_cats]) }

        context 'without a viewer' do
          let(:viewer) { nil }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a viewer' do
          let(:viewer) { Fabricate(:account, username: 'viewer') }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a moderator as viewer' do
          let(:viewer) { Fabricate(:moderator_user).account }

          it 'does not include remote instances statuses' do
            expect(subject).to include(local_status.id)
            expect(subject).to_not include(remote_status.id)
          end
        end
      end

      context 'with a remote_only option set' do
        subject { described_class.new(tag_cats, viewer, remote: true).get(20).map(&:id) }

        let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
        let!(:local_status)   { status_tagged_with_cats }
        let!(:remote_status)  { Fabricate(:status, account: remote_account, tags: [tag_cats]) }

        context 'without a viewer' do
          let(:viewer) { nil }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a viewer' do
          let(:viewer) { Fabricate(:account, username: 'viewer') }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a moderator as viewer' do
          let(:viewer) { Fabricate(:moderator_user).account }

          it 'includes remote statuses only' do
            expect(subject).to_not include(local_status.id)
            expect(subject).to include(remote_status.id)
          end
        end
      end
    end

    context 'when local_topic_feed_access is disabled' do
      before do
        Setting.local_topic_feed_access = 'disabled'
      end

      context 'without local_only option' do
        subject { described_class.new(tag_cats, viewer).get(20).map(&:id) }

        let(:viewer) { nil }

        let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
        let!(:local_status)   { status_tagged_with_cats }
        let!(:remote_status)  { Fabricate(:status, account: remote_account, tags: [tag_cats]) }

        context 'without a viewer' do
          let(:viewer) { nil }

          it 'does not include local instances statuses' do
            expect(subject).to_not include(local_status.id)
            expect(subject).to include(remote_status.id)
          end
        end

        context 'with a viewer' do
          let(:viewer) { Fabricate(:account, username: 'viewer') }

          it 'does not include local instances statuses' do
            expect(subject).to_not include(local_status.id)
            expect(subject).to include(remote_status.id)
          end
        end
      end

      context 'with a local_only option set' do
        subject { described_class.new(tag_cats, viewer, local: true).get(20).map(&:id) }

        let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
        let!(:local_status)   { status_tagged_with_cats }
        let!(:remote_status)  { Fabricate(:status, account: remote_account, tags: [tag_cats]) }

        context 'without a viewer' do
          let(:viewer) { nil }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a viewer' do
          let(:viewer) { Fabricate(:account, username: 'viewer') }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a moderator as viewer' do
          let(:viewer) { Fabricate(:moderator_user).account }

          it 'does not include remote instances statuses' do
            expect(subject).to include(local_status.id)
            expect(subject).to_not include(remote_status.id)
          end
        end
      end

      context 'with a remote_only option set' do
        subject { described_class.new(tag_cats, viewer, remote: true).get(20).map(&:id) }

        let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
        let!(:local_status)   { status_tagged_with_cats }
        let!(:remote_status)  { Fabricate(:status, account: remote_account, tags: [tag_cats]) }

        context 'without a viewer' do
          let(:viewer) { nil }

          it 'does not include local instances statuses' do
            expect(subject).to_not include(local_status.id)
            expect(subject).to include(remote_status.id)
          end
        end

        context 'with a viewer' do
          let(:viewer) { Fabricate(:account, username: 'viewer') }

          it 'does not include local instances statuses' do
            expect(subject).to_not include(local_status.id)
            expect(subject).to include(remote_status.id)
          end
        end
      end
    end

    context 'when remote_topic_feed_access is disabled' do
      before do
        Setting.remote_topic_feed_access = 'disabled'
      end

      context 'without local_only option' do
        subject { described_class.new(tag_cats, viewer).get(20).map(&:id) }

        let(:viewer) { nil }

        let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
        let!(:local_status)   { status_tagged_with_cats }
        let!(:remote_status)  { Fabricate(:status, account: remote_account, tags: [tag_cats]) }

        context 'without a viewer' do
          let(:viewer) { nil }

          it 'does not include remote instances statuses' do
            expect(subject).to include(local_status.id)
            expect(subject).to_not include(remote_status.id)
          end
        end

        context 'with a viewer' do
          let(:viewer) { Fabricate(:account, username: 'viewer') }

          it 'does not include remote instances statuses' do
            expect(subject).to include(local_status.id)
            expect(subject).to_not include(remote_status.id)
          end

          it 'is not affected by personal domain blocks' do
            viewer.block_domain!('test.com')
            expect(subject).to include(local_status.id)
            expect(subject).to_not include(remote_status.id)
          end
        end
      end

      context 'with a local_only option set' do
        subject { described_class.new(tag_cats, viewer, local: true).get(20).map(&:id) }

        let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
        let!(:local_status)   { status_tagged_with_cats }
        let!(:remote_status)  { Fabricate(:status, account: remote_account, tags: [tag_cats]) }

        context 'without a viewer' do
          let(:viewer) { nil }

          it 'does not include remote instances statuses' do
            expect(subject).to include(local_status.id)
            expect(subject).to_not include(remote_status.id)
          end
        end

        context 'with a viewer' do
          let(:viewer) { Fabricate(:account, username: 'viewer') }

          it 'does not include remote instances statuses' do
            expect(subject).to include(local_status.id)
            expect(subject).to_not include(remote_status.id)
          end

          it 'is not affected by personal domain blocks' do
            viewer.block_domain!('test.com')
            expect(subject).to include(local_status.id)
            expect(subject).to_not include(remote_status.id)
          end
        end
      end

      context 'with a remote_only option set' do
        subject { described_class.new(tag_cats, viewer, remote: true).get(20).map(&:id) }

        let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
        let!(:local_status)   { status_tagged_with_cats }
        let!(:remote_status)  { Fabricate(:status, account: remote_account, tags: [tag_cats]) }

        context 'without a viewer' do
          let(:viewer) { nil }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a viewer' do
          let(:viewer) { Fabricate(:account, username: 'viewer') }

          it 'returns an empty list' do
            expect(subject).to be_empty
          end
        end

        context 'with a moderator as viewer' do
          let(:viewer) { Fabricate(:moderator_user).account }

          it 'does not include local instances statuses' do
            expect(subject).to_not include(local_status.id)
            expect(subject).to include(remote_status.id)
          end
        end
      end
    end
  end
end
