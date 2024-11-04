# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountStatusesFilter do
  let(:account) { Fabricate(:account) }
  let(:current_account) { nil }
  let(:params) { {} }

  def status!(visibility)
    Fabricate(:status, account: account, visibility: visibility)
  end

  def status_with_tag!(visibility, tag)
    Fabricate(:status, account: account, visibility: visibility, tags: [tag])
  end

  def status_with_parent!(visibility)
    Fabricate(:status, account: account, visibility: visibility, thread: Fabricate(:status))
  end

  def status_with_reblog!(visibility)
    Fabricate(:status, account: account, visibility: visibility, reblog: Fabricate(:status))
  end

  def status_with_mention!(visibility, mentioned_account = nil)
    Fabricate(:status, account: account, visibility: visibility).tap do |status|
      Fabricate(:mention, status: status, account: mentioned_account || Fabricate(:account))
    end
  end

  def status_with_media_attachment!(visibility)
    Fabricate(:status, account: account, visibility: visibility).tap do |status|
      Fabricate(:media_attachment, account: account, status: status)
    end
  end

  describe '#results' do
    subject { described_class.new(account, current_account, params).results }

    let(:tag) { Fabricate(:tag) }

    before do
      status!(:public)
      status!(:unlisted)
      status!(:private)
      status_with_parent!(:public)
      status_with_reblog!(:public)
      status_with_tag!(:public, tag)
      status_with_mention!(:direct)
      status_with_media_attachment!(:public)
    end

    shared_examples 'filter params' do
      it 'respects param options in results' do
        expect(results_for(only_media: true))
          .to all(satisfy(&:with_media?))

        expect(results_for(tagged: tag.name))
          .to all(satisfy { |status| status.tags.include?(tag) })

        expect(results_for(exclude_replies: true))
          .to all(satisfy { |status| !status.reply? })

        expect(results_for(exclude_reblogs: true))
          .to all(satisfy { |status| !status.reblog? })
      end

      def results_for(params)
        described_class
          .new(account, current_account, params)
          .results
      end
    end

    context 'when accessed anonymously' do
      let(:current_account) { nil }
      let(:direct_status) { nil }

      it 'returns only public statuses, public replies, and public reblogs' do
        expect(results_unique_visibilities).to match_array %w(unlisted public)

        expect(results_in_reply_to_ids).to_not be_empty

        expect(results_reblog_of_ids).to_not be_empty
      end

      it_behaves_like 'filter params'
    end

    context 'when accessed with a blocked account' do
      let(:current_account) { Fabricate(:account) }

      before do
        account.block!(current_account)
      end

      it 'returns nothing' do
        expect(subject.to_a).to be_empty
      end
    end

    context 'when accessed by self' do
      let(:current_account) { account }

      it 'returns all statuses, replies, and reblogs' do
        expect(results_unique_visibilities).to match_array %w(direct private unlisted public)

        expect(results_in_reply_to_ids).to_not be_empty

        expect(results_reblog_of_ids).to_not be_empty
      end

      it_behaves_like 'filter params'
    end

    context 'when accessed by a follower' do
      let(:current_account) { Fabricate(:account) }

      before do
        current_account.follow!(account)
      end

      it 'returns private statuses, replies, and reblogs' do
        expect(results_unique_visibilities).to match_array %w(private unlisted public)

        expect(results_in_reply_to_ids).to_not be_empty

        expect(results_reblog_of_ids).to_not be_empty
      end

      context 'when there is a direct status mentioning the non-follower' do
        let!(:direct_status) { status_with_mention!(:direct, current_account) }

        it 'returns the direct status' do
          expect(results_ids).to include(direct_status.id)
        end
      end

      it_behaves_like 'filter params'
    end

    context 'when accessed by a non-follower' do
      let(:current_account) { Fabricate(:account) }

      it 'returns only public statuses, replies, and reblogs' do
        expect(results_unique_visibilities).to match_array %w(unlisted public)

        expect(results_in_reply_to_ids).to_not be_empty

        expect(results_reblog_of_ids).to_not be_empty
      end

      context 'when there is a private status mentioning the non-follower' do
        let!(:private_status) { status_with_mention!(:private, current_account) }

        it 'returns the private status' do
          expect(results_ids).to include(private_status.id)
        end
      end

      context 'when blocking a reblogged account' do
        let(:reblog) { status_with_reblog!('public') }

        before do
          current_account.block!(reblog.reblog.account)
        end

        it 'does not return reblog of blocked account' do
          expect(results_ids).to_not include(reblog.id)
        end
      end

      context 'when blocking a reblogged domain' do
        let(:other_account) { Fabricate(:account, domain: 'example.com') }
        let(:reblogging_status) { Fabricate(:status, account: other_account) }
        let!(:reblog) { Fabricate(:status, account: account, visibility: 'public', reblog: reblogging_status) }

        before do
          current_account.block_domain!(other_account.domain)
        end

        it 'does not return reblog of blocked domain' do
          expect(results_ids).to_not include(reblog.id)
        end
      end

      context 'when blocking an unrelated domain' do
        let(:other_account) { Fabricate(:account, domain: nil) }
        let(:reblogging_status) { Fabricate(:status, account: other_account, visibility: 'public') }
        let!(:reblog) { Fabricate(:status, account: account, visibility: 'public', reblog: reblogging_status) }

        before do
          current_account.block_domain!('example.com')
        end

        it 'returns the reblog from the non-blocked domain' do
          expect(results_ids).to include(reblog.id)
        end
      end

      context 'when muting a reblogged account' do
        let(:reblog) { status_with_reblog!('public') }

        before do
          current_account.mute!(reblog.reblog.account)
        end

        it 'does not return reblog of muted account' do
          expect(results_ids).to_not include(reblog.id)
        end
      end

      context 'when blocked by a reblogged account' do
        let(:reblog) { status_with_reblog!('public') }

        before do
          reblog.reblog.account.block!(current_account)
        end

        it 'does not return reblog of blocked-by account' do
          expect(results_ids).to_not include(reblog.id)
        end
      end

      it_behaves_like 'filter params'
    end

    private

    def results_unique_visibilities
      subject.pluck(:visibility).uniq
    end

    def results_in_reply_to_ids
      subject.pluck(:in_reply_to_id)
    end

    def results_reblog_of_ids
      subject.pluck(:reblog_of_id)
    end

    def results_ids
      subject.pluck(:id)
    end
  end
end
