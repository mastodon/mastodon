shared_examples 'StatusTimeline' do
  describe '.as_home_timeline' do
    let(:account) { Fabricate(:account) }
    let(:followed) { Fabricate(:account) }
    let(:not_followed) { Fabricate(:account) }

    before do
      Fabricate(:follow, account: account, target_account: followed)

      @self_status = Fabricate(:status, account: account, visibility: :public)
      @self_direct_status = Fabricate(:status, account: account, visibility: :direct)
      @followed_status = Fabricate(:status, account: followed, visibility: :public)
      @followed_direct_status = Fabricate(:status, account: followed, visibility: :direct)
      @not_followed_status = Fabricate(:status, account: not_followed, visibility: :public)

      @results = described_class.as_home_timeline(account)
    end

    it 'includes statuses from self' do
      expect(@results).to include(@self_status)
    end

    it 'includes direct statuses from self' do
      expect(@results).to include(@self_direct_status)
    end

    it 'includes statuses from followed' do
      expect(@results).to include(@followed_status)
    end

    it 'includes direct statuses mentioning recipient from followed' do
      Fabricate(:mention, account: account, status: @followed_direct_status)
      expect(@results).to include(@followed_direct_status)
    end

    it 'does not include direct statuses not mentioning recipient from followed' do
      expect(@results).not_to include(@followed_direct_status)
    end

    it 'does not include statuses from non-followed' do
      expect(@results).not_to include(@not_followed_status)
    end
  end

  describe '.as_public_timeline' do
    it 'only includes statuses with public visibility' do
      public_status = Fabricate(:status, visibility: :public)
      private_status = Fabricate(:status, visibility: :private)

      results = described_class.as_public_timeline
      expect(results).to include(public_status)
      expect(results).not_to include(private_status)
    end

    it 'does not include replies' do
      status = Fabricate(:status)
      reply = Fabricate(:status, in_reply_to_id: status.id)

      results = described_class.as_public_timeline
      expect(results).to include(status)
      expect(results).not_to include(reply)
    end

    it 'does not include boosts' do
      status = Fabricate(:status)
      boost = Fabricate(:status, reblog_of_id: status.id)

      results = described_class.as_public_timeline
      expect(results).to include(status)
      expect(results).not_to include(boost)
    end

    it 'filters out silenced accounts' do
      account = Fabricate(:account)
      silenced_account = Fabricate(:account, silenced: true)
      status = Fabricate(:status, account: account)
      silenced_status = Fabricate(:status, account: silenced_account)

      results = described_class.as_public_timeline
      expect(results).to include(status)
      expect(results).not_to include(silenced_status)
    end

    context 'without local_only option' do
      let(:viewer) { nil }

      let!(:local_account)  { Fabricate(:account, domain: nil) }
      let!(:remote_account) { Fabricate(:account, domain: 'test.com') }
      let!(:local_status)   { Fabricate(:status, account: local_account) }
      let!(:remote_status)  { Fabricate(:status, account: remote_account) }

      subject { described_class.as_public_timeline(account: viewer, local_only: false) }

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

      subject { described_class.as_public_timeline(account: viewer, local_only: true) }

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

        results = described_class.as_public_timeline(account: @account)
        expect(results).not_to include(blocked_status)
      end

      it 'excludes statuses from accounts who have blocked the account' do
        blocked = Fabricate(:account)
        Fabricate(:block, account: blocked, target_account: @account)
        blocked_status = Fabricate(:status, account: blocked)

        results = described_class.as_public_timeline(account: @account)
        expect(results).not_to include(blocked_status)
      end

      it 'excludes statuses from accounts muted by the account' do
        muted = Fabricate(:account)
        Fabricate(:mute, account: @account, target_account: muted)
        muted_status = Fabricate(:status, account: muted)

        results = described_class.as_public_timeline(account: @account)
        expect(results).not_to include(muted_status)
      end

      it 'excludes statuses from accounts from personally blocked domains' do
        blocked = Fabricate(:account, domain: 'example.com')
        @account.block_domain!(blocked.domain)
        blocked_status = Fabricate(:status, account: blocked)

        results = described_class.as_public_timeline(account: @account)
        expect(results).not_to include(blocked_status)
      end

      context 'with language preferences' do
        it 'excludes statuses in languages not allowed by the account user' do
          user = Fabricate(:user, filtered_languages: [:fr])
          @account.update(user: user)
          en_status = Fabricate(:status, language: 'en')
          es_status = Fabricate(:status, language: 'es')
          fr_status = Fabricate(:status, language: 'fr')

          results = described_class.as_public_timeline(account: @account)
          expect(results).to include(en_status)
          expect(results).to include(es_status)
          expect(results).not_to include(fr_status)
        end

        it 'includes all languages when user does not have a setting' do
          user = Fabricate(:user, filtered_languages: [])
          @account.update(user: user)

          en_status = Fabricate(:status, language: 'en')
          es_status = Fabricate(:status, language: 'es')

          results = described_class.as_public_timeline(account: @account)
          expect(results).to include(en_status)
          expect(results).to include(es_status)
        end

        it 'includes all languages when account does not have a user' do
          expect(@account.user).to be_nil
          en_status = Fabricate(:status, language: 'en')
          es_status = Fabricate(:status, language: 'es')

          results = described_class.as_public_timeline(account: @account)
          expect(results).to include(en_status)
          expect(results).to include(es_status)
        end
      end

      context 'where that account is silenced' do
        it 'includes statuses from other accounts that are silenced' do
          @account.update(silenced: true)
          other_silenced_account = Fabricate(:account, silenced: true)
          other_status = Fabricate(:status, account: other_silenced_account)

          results = described_class.as_public_timeline(account: @account)
          expect(results).to include(other_status)
        end
      end
    end
  end

  describe '.as_tag_timeline' do
    it 'includes statuses with a tag' do
      tag = Fabricate(:tag)
      status = Fabricate(:status, tags: [tag])
      other = Fabricate(:status)

      results = described_class.as_tag_timeline(tag)
      expect(results).to include(status)
      expect(results).not_to include(other)
    end

    it 'allows replies to be included' do
      original = Fabricate(:status)
      tag = Fabricate(:tag)
      status = Fabricate(:status, tags: [tag], in_reply_to_id: original.id)

      results = described_class.as_tag_timeline(tag)
      expect(results).to include(status)
    end
  end
end
