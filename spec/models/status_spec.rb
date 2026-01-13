# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status do
  subject { Fabricate(:status, account: alice) }

  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }
  let(:other) { Fabricate(:status, account: bob, text: 'Skulls for the skull god! The enemy\'s gates are sideways!') }

  it_behaves_like 'Status::Visibility'

  describe '#local?' do
    it 'returns true when no remote URI is set' do
      expect(subject.local?).to be true
    end

    it 'returns false if a remote URI is set' do
      alice.update(domain: 'example.com')
      subject.save
      expect(subject.local?).to be false
    end

    it 'returns true if a URI is set and `local` is true' do
      subject.update(uri: 'example.com', local: true)
      expect(subject.local?).to be true
    end
  end

  describe '#reblog?' do
    it 'returns true when the status reblogs another status' do
      subject.reblog = other
      expect(subject.reblog?).to be true
    end

    it 'returns false if the status is self-contained' do
      expect(subject.reblog?).to be false
    end
  end

  describe '#reply?' do
    it 'returns true if the status references another' do
      subject.thread = other
      expect(subject.reply?).to be true
    end

    it 'returns false if the status is self-contained' do
      expect(subject.reply?).to be false
    end
  end

  describe '#verb' do
    context 'when destroyed?' do
      it 'returns :delete' do
        subject.destroy!
        expect(subject.verb).to be :delete
      end
    end

    context 'when not destroyed?' do
      context 'when reblog?' do
        it 'returns :share' do
          subject.reblog = other
          expect(subject.verb).to be :share
        end
      end

      context 'when not reblog?' do
        it 'returns :post' do
          subject.reblog = nil
          expect(subject.verb).to be :post
        end
      end
    end
  end

  describe '#object_type' do
    it 'is note when the status is self-contained' do
      expect(subject.object_type).to be :note
    end

    it 'is comment when the status replies to another' do
      subject.thread = other
      expect(subject.object_type).to be :comment
    end
  end

  describe '#content' do
    it 'returns the text of the status if it is not a reblog' do
      expect(subject.content).to eql subject.text
    end

    it 'returns the text of the reblogged status' do
      subject.reblog = other
      expect(subject.content).to eql other.text
    end
  end

  describe '#target' do
    it 'returns nil if the status is self-contained' do
      expect(subject.target).to be_nil
    end

    it 'returns nil if the status is a reply' do
      subject.thread = other
      expect(subject.target).to be_nil
    end

    it 'returns the reblogged status' do
      subject.reblog = other
      expect(subject.target).to eq other
    end
  end

  describe '#reblogs_count' do
    it 'is the number of reblogs' do
      Fabricate(:status, account: bob, reblog: subject)
      Fabricate(:status, account: alice, reblog: subject)

      expect(subject.reblogs_count).to eq 2
    end

    it 'is decremented when reblog is removed' do
      reblog = Fabricate(:status, account: bob, reblog: subject)
      expect(subject.reblogs_count).to eq 1
      reblog.destroy
      expect(subject.reblogs_count).to eq 0
    end

    it 'does not fail when original is deleted before reblog' do
      reblog = Fabricate(:status, account: bob, reblog: subject)
      expect(subject.reblogs_count).to eq 1
      expect { subject.destroy }.to_not raise_error
      expect(described_class.find_by(id: reblog.id)).to be_nil
    end
  end

  describe '#untrusted_reblogs_count' do
    before do
      alice.update(domain: 'example.com')
      subject.status_stat.tap do |status_stat|
        status_stat.untrusted_reblogs_count = 0
        status_stat.save
      end
      subject.save
    end

    it 'is incremented by the number of reblogs' do
      Fabricate(:status, account: bob, reblog: subject)
      Fabricate(:status, account: alice, reblog: subject)

      expect(subject.untrusted_reblogs_count).to eq 2
    end

    it 'is decremented when reblog is removed' do
      reblog = Fabricate(:status, account: bob, reblog: subject)
      expect(subject.untrusted_reblogs_count).to eq 1
      reblog.destroy
      expect(subject.untrusted_reblogs_count).to eq 0
    end
  end

  describe '#replies_count' do
    it 'is the number of replies' do
      Fabricate(:status, account: bob, thread: subject)
      expect(subject.replies_count).to eq 1
    end

    it 'is decremented when reply is removed' do
      reply = Fabricate(:status, account: bob, thread: subject)
      expect(subject.replies_count).to eq 1
      reply.destroy
      expect(subject.replies_count).to eq 0
    end
  end

  describe '#favourites_count' do
    it 'is the number of favorites' do
      Fabricate(:favourite, account: bob, status: subject)
      Fabricate(:favourite, account: alice, status: subject)

      expect(subject.favourites_count).to eq 2
    end

    it 'is decremented when favourite is removed' do
      favourite = Fabricate(:favourite, account: bob, status: subject)
      expect(subject.favourites_count).to eq 1
      favourite.destroy
      expect(subject.favourites_count).to eq 0
    end
  end

  describe '.not_replying_to_account' do
    let(:account) { Fabricate :account }
    let!(:status_from_account) { Fabricate :status, account: account }
    let!(:reply_to_account_status) { Fabricate :status, thread: status_from_account }
    let!(:reply_to_other) { Fabricate :status, thread: Fabricate(:status) }

    it 'returns records not in reply to provided account' do
      expect(described_class.not_replying_to_account(account))
        .to not_include(reply_to_account_status)
        .and include(reply_to_other)
    end
  end

  describe '#untrusted_favourites_count' do
    before do
      alice.update(domain: 'example.com')
      subject.status_stat.tap do |status_stat|
        status_stat.untrusted_favourites_count = 0
        status_stat.save
      end
      subject.save
    end

    it 'is incremented by favorites' do
      Fabricate(:favourite, account: bob, status: subject)
      Fabricate(:favourite, account: alice, status: subject)

      expect(subject.untrusted_favourites_count).to eq 2
    end

    it 'is decremented when favourite is removed' do
      favourite = Fabricate(:favourite, account: bob, status: subject)
      expect(subject.untrusted_favourites_count).to eq 1
      favourite.destroy
      expect(subject.untrusted_favourites_count).to eq 0
    end
  end

  describe '#proper' do
    it 'is itself for original statuses' do
      expect(subject.proper).to eq subject
    end

    it 'is the source status for reblogs' do
      subject.reblog = other
      expect(subject.proper).to eq other
    end
  end

  describe '#reported?' do
    context 'when the status is not reported' do
      it 'returns false' do
        expect(subject.reported?).to be false
      end
    end

    context 'when the status is part of an open report' do
      before do
        Fabricate(:report, target_account: subject.account, status_ids: [subject.id])
      end

      it 'returns true' do
        expect(subject.reported?).to be true
      end
    end

    context 'when the status is part of a closed report with an account warning mentioning the account' do
      before do
        report = Fabricate(:report, target_account: subject.account, status_ids: [subject.id])
        report.resolve!(Fabricate(:account))
        Fabricate(:account_warning, target_account: subject.account, status_ids: [subject.id], report: report)
      end

      it 'returns true' do
        expect(subject.reported?).to be true
      end
    end

    context 'when the status is part of a closed report with an account warning not mentioning the account' do
      before do
        report = Fabricate(:report, target_account: subject.account, status_ids: [subject.id])
        report.resolve!(Fabricate(:account))
        Fabricate(:account_warning, target_account: subject.account, report: report)
      end

      it 'returns false' do
        expect(subject.reported?).to be false
      end
    end
  end

  describe '#ordered_media_attachments' do
    let(:status) { Fabricate(:status) }

    let(:first_attachment) { Fabricate(:media_attachment) }
    let(:second_attachment) { Fabricate(:media_attachment) }
    let(:last_attachment) { Fabricate(:media_attachment) }
    let(:extra_attachment) { Fabricate(:media_attachment) }

    before do
      stub_const('Status::MEDIA_ATTACHMENTS_LIMIT', 3)

      # Add attachments out of order
      status.media_attachments << second_attachment
      status.media_attachments << last_attachment
      status.media_attachments << extra_attachment
      status.media_attachments << first_attachment
    end

    context 'when ordered_media_attachment_ids is not set' do
      it 'returns up to MEDIA_ATTACHMENTS_LIMIT attachments' do
        expect(status.ordered_media_attachments.size).to eq Status::MEDIA_ATTACHMENTS_LIMIT
      end
    end

    context 'when ordered_media_attachment_ids is set' do
      before do
        status.update!(ordered_media_attachment_ids: [first_attachment.id, second_attachment.id, last_attachment.id, extra_attachment.id])
      end

      it 'returns up to MEDIA_ATTACHMENTS_LIMIT attachments in the expected order' do
        expect(status.ordered_media_attachments).to eq [first_attachment, second_attachment, last_attachment]
      end
    end
  end

  describe '.mutes_map' do
    subject { described_class.mutes_map([status.conversation.id], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    it 'contains true value' do
      account.mute_conversation!(status.conversation)
      expect(subject[status.conversation.id]).to be true
    end
  end

  describe '.favourites_map' do
    subject { described_class.favourites_map([status], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    it 'contains true value' do
      Fabricate(:favourite, status: status, account: account)
      expect(subject[status.id]).to be true
    end
  end

  describe '.reblogs_map' do
    subject { described_class.reblogs_map([status], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    it 'contains true value' do
      Fabricate(:status, account: account, reblog: status)
      expect(subject[status.id]).to be true
    end
  end

  describe '.only_reblogs' do
    let!(:status) { Fabricate :status }
    let!(:reblog) { Fabricate :status, reblog: Fabricate(:status) }

    it 'returns the expected statuses' do
      expect(described_class.only_reblogs)
        .to include(reblog)
        .and not_include(status)
    end
  end

  describe '.only_polls' do
    let!(:poll_status) { Fabricate :status, poll: Fabricate(:poll) }
    let!(:no_poll_status) { Fabricate :status }

    it 'returns the expected statuses' do
      expect(described_class.only_polls)
        .to include(poll_status)
        .and not_include(no_poll_status)
    end
  end

  describe '.without_polls' do
    let!(:poll_status) { Fabricate :status, poll: Fabricate(:poll) }
    let!(:no_poll_status) { Fabricate :status }

    it 'returns the expected statuses' do
      expect(described_class.without_polls)
        .to not_include(poll_status)
        .and include(no_poll_status)
    end
  end

  describe '.tagged_with' do
    let(:tag_cats) { Fabricate(:tag, name: 'cats') }
    let(:tag_dogs) { Fabricate(:tag, name: 'dogs') }
    let(:tag_zebras) { Fabricate(:tag, name: 'zebras') }
    let!(:status_with_tag_cats) { Fabricate(:status, tags: [tag_cats]) }
    let!(:status_with_tag_dogs) { Fabricate(:status, tags: [tag_dogs]) }
    let!(:status_tagged_with_zebras) { Fabricate(:status, tags: [tag_zebras]) }
    let!(:status_without_tags) { Fabricate(:status, tags: []) }
    let!(:status_with_all_tags) { Fabricate(:status, tags: [tag_cats, tag_dogs, tag_zebras]) }

    context 'when given one tag' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with([tag_cats.id]))
          .to include(status_with_tag_cats, status_with_all_tags)
          .and not_include(status_without_tags)
        expect(described_class.tagged_with([tag_dogs.id]))
          .to include(status_with_tag_dogs, status_with_all_tags)
          .and not_include(status_without_tags)
        expect(described_class.tagged_with([tag_zebras.id]))
          .to include(status_tagged_with_zebras, status_with_all_tags)
          .and not_include(status_without_tags)
      end
    end

    context 'when given multiple tags' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with([tag_cats.id, tag_dogs.id]))
          .to include(status_with_tag_cats, status_with_tag_dogs, status_with_all_tags)
          .and not_include(status_without_tags)
        expect(described_class.tagged_with([tag_cats.id, tag_zebras.id]))
          .to include(status_with_tag_cats, status_tagged_with_zebras, status_with_all_tags)
          .and not_include(status_without_tags)
        expect(described_class.tagged_with([tag_dogs.id, tag_zebras.id]))
          .to include(status_with_tag_dogs, status_tagged_with_zebras, status_with_all_tags)
          .and not_include(status_without_tags)
      end
    end
  end

  describe '.tagged_with_all' do
    let(:tag_cats) { Fabricate(:tag, name: 'cats') }
    let(:tag_dogs) { Fabricate(:tag, name: 'dogs') }
    let(:tag_zebras) { Fabricate(:tag, name: 'zebras') }
    let!(:status_with_tag_cats) { Fabricate(:status, tags: [tag_cats]) }
    let!(:status_with_tag_dogs) { Fabricate(:status, tags: [tag_dogs]) }
    let!(:status_tagged_with_zebras) { Fabricate(:status, tags: [tag_zebras]) }
    let!(:status_without_tags) { Fabricate(:status, tags: []) }
    let!(:status_with_all_tags) { Fabricate(:status, tags: [tag_cats, tag_dogs]) }

    context 'when given one tag' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with_all([tag_cats.id]))
          .to include(status_with_tag_cats, status_with_all_tags)
          .and not_include(status_without_tags)
        expect(described_class.tagged_with_all([tag_dogs.id]))
          .to include(status_with_tag_dogs, status_with_all_tags)
          .and not_include(status_without_tags)
        expect(described_class.tagged_with_all([tag_zebras.id]))
          .to include(status_tagged_with_zebras)
          .and not_include(status_without_tags)
      end
    end

    context 'when given multiple tags' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with_all([tag_cats.id, tag_dogs.id]))
          .to include(status_with_all_tags)
        expect(described_class.tagged_with_all([tag_cats.id, tag_zebras.id]))
          .to eq []
        expect(described_class.tagged_with_all([tag_dogs.id, tag_zebras.id]))
          .to eq []
      end
    end
  end

  describe '.tagged_with_none' do
    let(:tag_cats) { Fabricate(:tag, name: 'cats') }
    let(:tag_dogs) { Fabricate(:tag, name: 'dogs') }
    let(:tag_zebras) { Fabricate(:tag, name: 'zebras') }
    let!(:status_with_tag_cats) { Fabricate(:status, tags: [tag_cats]) }
    let!(:status_with_tag_dogs) { Fabricate(:status, tags: [tag_dogs]) }
    let!(:status_tagged_with_zebras) { Fabricate(:status, tags: [tag_zebras]) }
    let!(:status_without_tags) { Fabricate(:status, tags: []) }
    let!(:status_with_all_tags) { Fabricate(:status, tags: [tag_cats, tag_dogs, tag_zebras]) }

    context 'when given one tag' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with_none([tag_cats.id]))
          .to include(status_with_tag_dogs, status_tagged_with_zebras, status_without_tags)
          .and not_include(status_with_all_tags)
        expect(described_class.tagged_with_none([tag_dogs.id]))
          .to include(status_with_tag_cats, status_tagged_with_zebras, status_without_tags)
          .and not_include(status_with_all_tags)
        expect(described_class.tagged_with_none([tag_zebras.id]))
          .to include(status_with_tag_cats, status_with_tag_dogs, status_without_tags)
          .and not_include(status_with_all_tags)
      end
    end

    context 'when given multiple tags' do
      it 'returns the expected statuses' do
        expect(described_class.tagged_with_none([tag_cats.id, tag_dogs.id]))
          .to include(status_tagged_with_zebras, status_without_tags)
          .and not_include(status_with_all_tags)
        expect(described_class.tagged_with_none([tag_cats.id, tag_zebras.id]))
          .to include(status_with_tag_dogs, status_without_tags)
          .and not_include(status_with_all_tags)
        expect(described_class.tagged_with_none([tag_dogs.id, tag_zebras.id]))
          .to include(status_with_tag_cats, status_without_tags)
          .and not_include(status_with_all_tags)
      end
    end
  end

  describe 'Validations' do
    context 'with a remote account' do
      subject { Fabricate.build :status, account: remote_account }

      let(:remote_account) { Fabricate :account, domain: 'example.com' }

      it { is_expected.to_not allow_value('').for(:uri) }
    end
  end

  describe 'Callbacks' do
    describe 'Stripping content when required' do
      context 'with a remote account' do
        subject { Fabricate.build :status, local: false, account:, text: '   text   ', spoiler_text: '   spoiler   ' }

        let(:account) { Fabricate.build :account, domain: 'host.example' }

        it 'preserves content' do
          expect { subject.valid? }
            .to not_change(subject, :text)
            .and not_change(subject, :spoiler_text)
        end
      end

      context 'with a local account' do
        let(:account) { Fabricate.build :account, domain: nil }

        context 'with populated fields' do
          subject { Fabricate.build :status, local: true, account:, text: '   text   ', spoiler_text: '   spoiler   ' }

          it 'strips content' do
            expect { subject.valid? }
              .to change(subject, :text).to('text')
              .and change(subject, :spoiler_text).to('spoiler')
          end
        end

        context 'with empty fields' do
          subject { Fabricate.build :status, local: true, account:, text: nil, spoiler_text: nil }

          it 'preserves content' do
            expect { subject.valid? }
              .to not_change(subject, :text)
              .and not_change(subject, :spoiler_text)
          end
        end
      end
    end

    describe 'Wiring up replies and conversations' do
      it 'sets account being replied to correctly over intermediary nodes' do
        first_status = Fabricate(:status, account: bob)
        intermediary = Fabricate(:status, thread: first_status, account: alice)
        final        = Fabricate(:status, thread: intermediary, account: alice)

        expect(final.in_reply_to_account_id).to eq bob.id
      end

      it 'creates new conversation for stand-alone status' do
        new_status = nil
        expect do
          new_status = described_class.create(account: alice, text: 'First')
        end.to change(Conversation, :count).by(1)

        expect(new_status.conversation_id).to_not be_nil
        expect(new_status.conversation.parent_status_id).to eq new_status.id
      end

      it 'keeps conversation of parent node' do
        parent = Fabricate(:status, text: 'First')
        expect(described_class.create(account: alice, thread: parent, text: 'Response').conversation_id).to eq parent.conversation_id
      end
    end

    describe 'Setting the `local` flag correctly' do
      it 'sets `local` to true for status by local account' do
        expect(described_class.create(account: alice, text: 'foo').local).to be true
      end

      it 'sets `local` to false for status by remote account' do
        alice.update(domain: 'example.com')
        expect(described_class.create(account: alice, text: 'foo').local).to be false
      end
    end

    describe 'after_create' do
      it 'saves ActivityPub uri as uri for local status' do
        status = described_class.create(account: alice, text: 'foo')
        status.reload
        expect(status.uri).to start_with('https://')
      end
    end
  end
end
