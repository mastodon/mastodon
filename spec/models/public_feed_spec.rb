require 'rails_helper'

RSpec.describe PublicFeed, type: :model do
  let(:account) { Fabricate(:account) }

  describe '#get' do
    subject { described_class.new(nil).get(20).map(&:id) }

    it 'only includes statuses with public visibility' do
      public_status = Fabricate(:status, visibility: :public)
      private_status = Fabricate(:status, visibility: :private)

      expect(subject).to include(public_status.id)
      expect(subject).not_to include(private_status.id)
    end

    it 'does not include replies' do
      status = Fabricate(:status)
      reply = Fabricate(:status, in_reply_to_id: status.id)

      expect(subject).to include(status.id)
      expect(subject).not_to include(reply.id)
    end

    it 'does not include boosts' do
      status = Fabricate(:status)
      boost = Fabricate(:status, reblog_of_id: status.id)

      expect(subject).to include(status.id)
      expect(subject).not_to include(boost.id)
    end

    it 'filters out silenced accounts' do
      account = Fabricate(:account)
      silenced_account = Fabricate(:account, silenced: true)
      status = Fabricate(:status, account: account)
      silenced_status = Fabricate(:status, account: silenced_account)

      expect(subject).to include(status.id)
      expect(subject).not_to include(silenced_status.id)
    end

    context 'without local_only option' do
      let(:viewer) { nil }

      let!(:local_account)  { Fabricate(:account, domain: nil) }
      let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
      let!(:local_status)   { Fabricate(:status, account: local_account) }
      let!(:remote_status)  { Fabricate(:status, account: remote_account) }

      subject { described_class.new(viewer).get(20).map(&:id) }

      context 'without a viewer' do
        let(:viewer) { nil }

        it 'includes remote instances statuses' do
          expect(subject).to include(remote_status.id)
        end

        it 'includes local statuses' do
          expect(subject).to include(local_status.id)
        end
      end

      context 'with a viewer' do
        let(:viewer) { Fabricate(:account, username: 'viewer') }

        it 'includes remote instances statuses' do
          expect(subject).to include(remote_status.id)
        end

        it 'includes local statuses' do
          expect(subject).to include(local_status.id)
        end
      end
    end

    context 'with a local_only option set' do
      let!(:local_account)  { Fabricate(:account, domain: nil) }
      let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
      let!(:local_status)   { Fabricate(:status, account: local_account) }
      let!(:remote_status)  { Fabricate(:status, account: remote_account) }

      subject { described_class.new(viewer, local: true).get(20).map(&:id) }

      context 'without a viewer' do
        let(:viewer) { nil }

        it 'does not include remote instances statuses' do
          expect(subject).to include(local_status.id)
          expect(subject).not_to include(remote_status.id)
        end
      end

      context 'with a viewer' do
        let(:viewer) { Fabricate(:account, username: 'viewer') }

        it 'does not include remote instances statuses' do
          expect(subject).to include(local_status.id)
          expect(subject).not_to include(remote_status.id)
        end

        it 'is not affected by personal domain blocks' do
          viewer.block_domain!('test.com')
          expect(subject).to include(local_status.id)
          expect(subject).not_to include(remote_status.id)
        end
      end
    end

    context 'with a remote_only option set' do
      let!(:local_account)  { Fabricate(:account, domain: nil) }
      let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
      let!(:local_status)   { Fabricate(:status, account: local_account) }
      let!(:remote_status)  { Fabricate(:status, account: remote_account) }

      subject { described_class.new(viewer, remote: true).get(20).map(&:id) }

      context 'without a viewer' do
        let(:viewer) { nil }

        it 'does not include local instances statuses' do
          expect(subject).not_to include(local_status.id)
          expect(subject).to include(remote_status.id)
        end
      end

      context 'with a viewer' do
        let(:viewer) { Fabricate(:account, username: 'viewer') }

        it 'does not include local instances statuses' do
          expect(subject).not_to include(local_status.id)
          expect(subject).to include(remote_status.id)
        end
      end
    end

    describe 'with an account passed in' do
      before do
        @account = Fabricate(:account)
      end

      subject { described_class.new(@account).get(20).map(&:id) }

      it 'excludes statuses from accounts blocked by the account' do
        blocked = Fabricate(:account)
        @account.block!(blocked)
        blocked_status = Fabricate(:status, account: blocked)

        expect(subject).not_to include(blocked_status.id)
      end

      it 'excludes statuses from accounts who have blocked the account' do
        blocker = Fabricate(:account)
        blocker.block!(@account)
        blocked_status = Fabricate(:status, account: blocker)

        expect(subject).not_to include(blocked_status.id)
      end

      it 'excludes statuses from accounts muted by the account' do
        muted = Fabricate(:account)
        @account.mute!(muted)
        muted_status = Fabricate(:status, account: muted)

        expect(subject).not_to include(muted_status.id)
      end

      it 'excludes statuses from accounts from personally blocked domains' do
        blocked = Fabricate(:account, domain: 'example.com')
        @account.block_domain!(blocked.domain)
        blocked_status = Fabricate(:status, account: blocked)

        expect(subject).not_to include(blocked_status.id)
      end

      context 'with language preferences' do
        it 'excludes statuses in languages not allowed by the account user' do
          user = Fabricate(:user, chosen_languages: [:en, :es])
          @account.update(user: user)
          en_status = Fabricate(:status, language: 'en')
          es_status = Fabricate(:status, language: 'es')
          fr_status = Fabricate(:status, language: 'fr')

          expect(subject).to include(en_status.id)
          expect(subject).to include(es_status.id)
          expect(subject).not_to include(fr_status.id)
        end

        it 'includes all languages when user does not have a setting' do
          user = Fabricate(:user, chosen_languages: nil)
          @account.update(user: user)

          en_status = Fabricate(:status, language: 'en')
          es_status = Fabricate(:status, language: 'es')

          expect(subject).to include(en_status.id)
          expect(subject).to include(es_status.id)
        end

        it 'includes all languages when account does not have a user' do
          expect(@account.user).to be_nil
          en_status = Fabricate(:status, language: 'en')
          es_status = Fabricate(:status, language: 'es')

          expect(subject).to include(en_status.id)
          expect(subject).to include(es_status.id)
        end
      end
    end
  end
end
