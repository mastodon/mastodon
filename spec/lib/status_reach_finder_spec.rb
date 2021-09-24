# frozen_string_literal: true

require 'rails_helper'

describe StatusReachFinder do
  describe '#inboxes' do
    context 'for a local status' do
      let(:parent_status) { nil }
      let(:alice) { Fabricate(:account, username: 'alice') }
      let(:status) { Fabricate(:status, account: alice, thread: parent_status) }

      subject { described_class.new(status) }

      context 'when it contains mentions of remote accounts' do
        let(:bob) { Fabricate(:account, username: 'bob', domain: 'foo.bar', protocol: :activitypub, inbox_url: 'https://foo.bar/inbox') }

        before do
          status.mentions.create!(account: bob)
        end

        it 'includes the inbox of the reblogger' do
          expect(subject.inboxes).to include 'https://foo.bar/inbox'
        end
      end

      context 'when it has been reblogged by a remote account' do
        let(:bob) { Fabricate(:account, username: 'bob', domain: 'foo.bar', protocol: :activitypub, inbox_url: 'https://foo.bar/inbox') }

        before do
          bob.statuses.create!(reblog: status)
        end

        it 'includes the inbox of the reblogger' do
          expect(subject.inboxes).to include 'https://foo.bar/inbox'
        end
      end

      context 'when it has been favourited by a remote account' do
        let(:bob) { Fabricate(:account, username: 'bob', domain: 'foo.bar', protocol: :activitypub, inbox_url: 'https://foo.bar/inbox') }

        before do
          bob.favourites.create!(status: status)
        end

        it 'includes the inbox of the favouriter' do
          expect(subject.inboxes).to include 'https://foo.bar/inbox'
        end
      end

      context 'when it has been replied to by a remote account' do
        let(:bob) { Fabricate(:account, username: 'bob', domain: 'foo.bar', protocol: :activitypub, inbox_url: 'https://foo.bar/inbox') }

        before do
          bob.statuses.create!(thread: status, text: 'Hoge')
        end

        it 'includes the inbox of the replier' do
          expect(subject.inboxes).to include 'https://foo.bar/inbox'
        end
      end

      context 'when it is a reply to a remote account' do
        let(:bob) { Fabricate(:account, username: 'bob', domain: 'foo.bar', protocol: :activitypub, inbox_url: 'https://foo.bar/inbox') }
        let(:parent_status) { Fabricate(:status, account: bob) }

        it 'includes the inbox of the replied-to account' do
          expect(subject.inboxes).to include 'https://foo.bar/inbox'
        end
      end
    end

    context 'for a remote status' do
      let(:parent_status) { nil }
      let(:alice) { Fabricate(:account, username: 'alice', domain: 'example.com') }
      let(:status) { Fabricate(:status, account: alice, thread: parent_status) }

      subject { described_class.new(status) }

      context 'when it is a reply to a local status' do
        let(:bob) { Fabricate(:account, username: 'bob', domain: 'foo.bar', protocol: :activitypub, inbox_url: 'https://foo.bar/inbox') }
        let(:tom) { Fabricate(:account, username: 'tom', domain: 'bar.baz', protocol: :activitypub, inbox_url: 'https://bar.baz/inbox') }
        let(:dan) { Fabricate(:account, username: 'dan', domain: 'baz.foo', protocol: :activitypub, inbox_url: 'https://baz.foo/inbox') }

        let(:parent_status) { Fabricate(:status) }

        before do
          bob.follow!(parent_status.account)
          tom.statuses.create!(reblog: parent_status)
          parent_status.mentions.create!(account: dan)
        end

        it 'includes inboxes of replied-to account\'s followers' do
          expect(subject.inboxes).to include 'https://foo.bar/inbox'
        end

        it 'includes inboxes of accounts that reblogged the replied-to status' do
          expect(subject.inboxes).to include 'https://bar.baz/inbox'
        end

        it 'includes inboxes of accounts mentioned in the replied-to status' do
          expect(subject.inboxes).to include 'https://baz.foo/inbox'
        end
      end

      context 'when it has been reblogged by a local account' do
        let(:bob) { Fabricate(:account, username: 'bob', domain: 'foo.bar', protocol: :activitypub, inbox_url: 'https://foo.bar/inbox') }
        let(:tom) { Fabricate(:account, username: 'tom') }

        before do
          bob.follow!(tom)
          tom.statuses.create!(reblog: status)
        end

        it 'includes inboxes of remote followers of the rebloggers' do
          expect(subject.inboxes).to include 'https://foo.bar/inbox'
        end
      end

      context 'when it is a reply to a remote status' do
        let(:bob) { Fabricate(:account, username: 'bob', domain: 'foo.bar', protocol: :activitypub, inbox_url: 'https://foo.bar/inbox') }
        let(:tom) { Fabricate(:account, username: 'tom', domain: 'bar.baz', protocol: :activitypub, inbox_url: 'https://bar.baz/inbox') }
        let(:dan) { Fabricate(:account, username: 'dan', domain: 'baz.foo', protocol: :activitypub, inbox_url: 'https://baz.foo/inbox') }

        let(:parent_status) { Fabricate(:status, account: bob) }

        before do
          parent_status.mentions.create!(account: dan)
          status.mentions.create!(account: tom)
        end

        it 'does not include inbox of replied-to account' do
          expect(subject.inboxes).to_not include 'https://foo.bar/inbox'
        end

        it 'does not include inboxes of accounts mentioned in the status' do
          expect(subject.inboxes).to_not include 'https://bar.baz/inbox'
        end

        it 'does not include inboxes of accounts mentioned in the replied-to status' do
          expect(subject.inboxes).to_not include 'https://baz.foo/inbox'
        end
      end
    end
  end
end
