require 'rails_helper'

RSpec.describe Status, type: :model do
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob') }
  let(:other) { Fabricate(:status, account: bob, text: 'Skulls for the skull god! The enemy\'s gates are sideways!') }

  subject { Fabricate(:status, account: alice) }

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
    context 'if destroyed?' do
      it 'returns :delete' do
        subject.destroy!
        expect(subject.verb).to be :delete
      end
    end

    context 'unless destroyed?' do
      context 'if reblog?' do
        it 'returns :share' do
          subject.reblog = other
          expect(subject.verb).to be :share
        end
      end

      context 'unless reblog?' do
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

  describe '#title' do
    # rubocop:disable Style/InterpolationCheck

    let(:account) { subject.account }

    context 'if destroyed?' do
      it 'returns "#{account.acct} deleted status"' do
        subject.destroy!
        expect(subject.title).to eq "#{account.acct} deleted status"
      end
    end

    context 'unless destroyed?' do
      context 'if reblog?' do
        it 'returns "#{account.acct} shared a status by #{reblog.account.acct}"' do
          reblog = subject.reblog = other
          expect(subject.title).to eq "#{account.acct} shared a status by #{reblog.account.acct}"
        end
      end

      context 'unless reblog?' do
        it 'returns "New status by #{account.acct}"' do
          subject.reblog = nil
          expect(subject.title).to eq "New status by #{account.acct}"
        end
      end
    end
  end

  describe '#hidden?' do
    context 'if private_visibility?' do
      it 'returns true' do
        subject.visibility = :private
        expect(subject.hidden?).to be true
      end
    end

    context 'if direct_visibility?' do
      it 'returns true' do
        subject.visibility = :direct
        expect(subject.hidden?).to be true
      end
    end

    context 'if public_visibility?' do
      it 'returns false' do
        subject.visibility = :public
        expect(subject.hidden?).to be false
      end
    end

    context 'if unlisted_visibility?' do
      it 'returns false' do
        subject.visibility = :unlisted
        expect(subject.hidden?).to be false
      end
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
      expect(Status.find_by(id: reblog.id)).to be_nil
    end
  end

  describe '#replies_count' do
    it 'is the number of replies' do
      reply = Fabricate(:status, account: bob, thread: subject)
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

  describe '#proper' do
    it 'is itself for original statuses' do
      expect(subject.proper).to eq subject
    end

    it 'is the source status for reblogs' do
      subject.reblog = other
      expect(subject.proper).to eq other
    end
  end

  describe '.mutes_map' do
    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    subject { Status.mutes_map([status.conversation.id], account) }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    it 'contains true value' do
      account.mute_conversation!(status.conversation)
      expect(subject[status.conversation.id]).to be true
    end
  end

  describe '.favourites_map' do
    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    subject { Status.favourites_map([status], account) }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    it 'contains true value' do
      Fabricate(:favourite, status: status, account: account)
      expect(subject[status.id]).to be true
    end
  end

  describe '.reblogs_map' do
    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    subject { Status.reblogs_map([status], account) }

    it 'returns a hash' do
      expect(subject).to be_a Hash
    end

    it 'contains true value' do
      Fabricate(:status, account: account, reblog: status)
      expect(subject[status.id]).to be true
    end
  end

  describe '.in_chosen_languages' do
    context 'for accounts with language filters' do
      let(:user) { Fabricate(:user, chosen_languages: ['en']) }

      it 'does not include statuses in not in chosen languages' do
        status = Fabricate(:status, language: 'de')
        expect(Status.in_chosen_languages(user.account)).not_to include status
      end

      it 'includes status with unknown language' do
        status = Fabricate(:status, language: nil)
        expect(Status.in_chosen_languages(user.account)).to include status
      end
    end
  end

  describe '.as_public_timeline' do
    it 'only includes statuses with public visibility' do
      public_status = Fabricate(:status, visibility: :public)
      private_status = Fabricate(:status, visibility: :private)

      results = Status.as_public_timeline
      expect(results).to include(public_status)
      expect(results).not_to include(private_status)
    end

    it 'does not include replies' do
      status = Fabricate(:status)
      reply = Fabricate(:status, in_reply_to_id: status.id)

      results = Status.as_public_timeline
      expect(results).to include(status)
      expect(results).not_to include(reply)
    end

    it 'does not include boosts' do
      status = Fabricate(:status)
      boost = Fabricate(:status, reblog_of_id: status.id)

      results = Status.as_public_timeline
      expect(results).to include(status)
      expect(results).not_to include(boost)
    end

    it 'filters out silenced accounts' do
      account = Fabricate(:account)
      silenced_account = Fabricate(:account, silenced: true)
      status = Fabricate(:status, account: account)
      silenced_status = Fabricate(:status, account: silenced_account)

      results = Status.as_public_timeline
      expect(results).to include(status)
      expect(results).not_to include(silenced_status)
    end

    context 'without local_only option' do
      let(:viewer) { nil }

      let!(:local_account)  { Fabricate(:account, domain: nil) }
      let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
      let!(:local_status)   { Fabricate(:status, account: local_account) }
      let!(:remote_status)  { Fabricate(:status, account: remote_account) }

      subject { Status.as_public_timeline(viewer, false) }

      context 'without a viewer' do
        let(:viewer) { nil }

        it 'includes remote instances statuses' do
          expect(subject).to include(remote_status)
        end

        it 'includes local statuses' do
          expect(subject).to include(local_status)
        end
      end

      context 'with a viewer' do
        let(:viewer) { Fabricate(:account, username: 'viewer') }

        it 'includes remote instances statuses' do
          expect(subject).to include(remote_status)
        end

        it 'includes local statuses' do
          expect(subject).to include(local_status)
        end
      end
    end

    context 'with a local_only option set' do
      let!(:local_account)  { Fabricate(:account, domain: nil) }
      let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
      let!(:local_status)   { Fabricate(:status, account: local_account) }
      let!(:remote_status)  { Fabricate(:status, account: remote_account) }

      subject { Status.as_public_timeline(viewer, true) }

      context 'without a viewer' do
        let(:viewer) { nil }

        it 'does not include remote instances statuses' do
          expect(subject).to include(local_status)
          expect(subject).not_to include(remote_status)
        end
      end

      context 'with a viewer' do
        let(:viewer) { Fabricate(:account, username: 'viewer') }

        it 'does not include remote instances statuses' do
          expect(subject).to include(local_status)
          expect(subject).not_to include(remote_status)
        end

        it 'is not affected by personal domain blocks' do
          viewer.block_domain!('test.com')
          expect(subject).to include(local_status)
          expect(subject).not_to include(remote_status)
        end
      end
    end

    describe 'with an account passed in' do
      before do
        @account = Fabricate(:account)
      end

      it 'excludes statuses from accounts blocked by the account' do
        blocked = Fabricate(:account)
        Fabricate(:block, account: @account, target_account: blocked)
        blocked_status = Fabricate(:status, account: blocked)

        results = Status.as_public_timeline(@account)
        expect(results).not_to include(blocked_status)
      end

      it 'excludes statuses from accounts who have blocked the account' do
        blocked = Fabricate(:account)
        Fabricate(:block, account: blocked, target_account: @account)
        blocked_status = Fabricate(:status, account: blocked)

        results = Status.as_public_timeline(@account)
        expect(results).not_to include(blocked_status)
      end

      it 'excludes statuses from accounts muted by the account' do
        muted = Fabricate(:account)
        Fabricate(:mute, account: @account, target_account: muted)
        muted_status = Fabricate(:status, account: muted)

        results = Status.as_public_timeline(@account)
        expect(results).not_to include(muted_status)
      end

      it 'excludes statuses from accounts from personally blocked domains' do
        blocked = Fabricate(:account, domain: 'example.com')
        @account.block_domain!(blocked.domain)
        blocked_status = Fabricate(:status, account: blocked)

        results = Status.as_public_timeline(@account)
        expect(results).not_to include(blocked_status)
      end

      context 'with language preferences' do
        it 'excludes statuses in languages not allowed by the account user' do
          user = Fabricate(:user, chosen_languages: [:en, :es])
          @account.update(user: user)
          en_status = Fabricate(:status, language: 'en')
          es_status = Fabricate(:status, language: 'es')
          fr_status = Fabricate(:status, language: 'fr')

          results = Status.as_public_timeline(@account)
          expect(results).to include(en_status)
          expect(results).to include(es_status)
          expect(results).not_to include(fr_status)
        end

        it 'includes all languages when user does not have a setting' do
          user = Fabricate(:user, chosen_languages: nil)
          @account.update(user: user)

          en_status = Fabricate(:status, language: 'en')
          es_status = Fabricate(:status, language: 'es')

          results = Status.as_public_timeline(@account)
          expect(results).to include(en_status)
          expect(results).to include(es_status)
        end

        it 'includes all languages when account does not have a user' do
          expect(@account.user).to be_nil
          en_status = Fabricate(:status, language: 'en')
          es_status = Fabricate(:status, language: 'es')

          results = Status.as_public_timeline(@account)
          expect(results).to include(en_status)
          expect(results).to include(es_status)
        end
      end
    end
  end

  describe '.as_tag_timeline' do
    it 'includes statuses with a tag' do
      tag = Fabricate(:tag)
      status = Fabricate(:status, tags: [tag])
      other = Fabricate(:status)

      results = Status.as_tag_timeline(tag)
      expect(results).to include(status)
      expect(results).not_to include(other)
    end

    it 'allows replies to be included' do
      original = Fabricate(:status)
      tag = Fabricate(:tag)
      status = Fabricate(:status, tags: [tag], in_reply_to_id: original.id)

      results = Status.as_tag_timeline(tag)
      expect(results).to include(status)
    end
  end

  describe '.permitted_for' do
    subject { described_class.permitted_for(target_account, account).pluck(:visibility) }

    let(:target_account) { alice }
    let(:account) { bob }
    let!(:public_status) { Fabricate(:status, account: target_account, visibility: 'public') }
    let!(:unlisted_status) { Fabricate(:status, account: target_account, visibility: 'unlisted') }
    let!(:private_status) { Fabricate(:status, account: target_account, visibility: 'private') }

    let!(:direct_status) do
      Fabricate(:status, account: target_account, visibility: 'direct').tap do |status|
        Fabricate(:mention, status: status, account: account)
      end
    end

    let!(:other_direct_status) do
      Fabricate(:status, account: target_account, visibility: 'direct').tap do |status|
        Fabricate(:mention, status: status)
      end
    end

    context 'given nil' do
      let(:account) { nil }
      let(:direct_status) { nil }
      it { is_expected.to eq(%w(unlisted public)) }
    end

    context 'given blocked account' do
      before do
        target_account.block!(account)
      end

      it { is_expected.to be_empty }
    end

    context 'given same account' do
      let(:account) { target_account }
      it { is_expected.to eq(%w(direct direct private unlisted public)) }
    end

    context 'given followed account' do
      before do
        account.follow!(target_account)
      end

      it { is_expected.to eq(%w(direct private unlisted public)) }
    end

    context 'given unfollowed account' do
      it { is_expected.to eq(%w(direct unlisted public)) }
    end
  end

  describe 'before_validation' do
    it 'sets account being replied to correctly over intermediary nodes' do
      first_status = Fabricate(:status, account: bob)
      intermediary = Fabricate(:status, thread: first_status, account: alice)
      final        = Fabricate(:status, thread: intermediary, account: alice)

      expect(final.in_reply_to_account_id).to eq bob.id
    end

    it 'creates new conversation for stand-alone status' do
      expect(Status.create(account: alice, text: 'First').conversation_id).to_not be_nil
    end

    it 'keeps conversation of parent node' do
      parent = Fabricate(:status, text: 'First')
      expect(Status.create(account: alice, thread: parent, text: 'Response').conversation_id).to eq parent.conversation_id
    end

    it 'sets `local` to true for status by local account' do
      expect(Status.create(account: alice, text: 'foo').local).to be true
    end

    it 'sets `local` to false for status by remote account' do
      alice.update(domain: 'example.com')
      expect(Status.create(account: alice, text: 'foo').local).to be false
    end
  end

  describe 'validation' do
    it 'disallow empty uri for remote status' do
      alice.update(domain: 'example.com')
      status = Fabricate.build(:status, uri: '', account: alice)
      expect(status).to model_have_error_on_field(:uri)
    end
  end

  describe 'after_create' do
    it 'saves ActivityPub uri as uri for local status' do
      status = Status.create(account: alice, text: 'foo')
      status.reload
      expect(status.uri).to start_with('https://')
    end
  end
end
