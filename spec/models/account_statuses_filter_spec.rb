# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountStatusesFilter do
  subject { described_class.new(account, current_account, params) }

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
      context 'with only_media param' do
        let(:params) { { only_media: true } }

        it 'returns only statuses with media' do
          expect(subject.results.all?(&:with_media?)).to be true
        end
      end

      context 'with tagged param' do
        let(:params) { { tagged: tag.name } }

        it 'returns only statuses with tag' do
          expect(subject.results.all? { |s| s.tags.include?(tag) }).to be true
        end
      end

      context 'with exclude_replies param' do
        let(:params) { { exclude_replies: true } }

        it 'returns only statuses that are not replies' do
          expect(subject.results.none?(&:reply?)).to be true
        end
      end

      context 'with exclude_reblogs param' do
        let(:params) { { exclude_reblogs: true } }

        it 'returns only statuses that are not reblogs' do
          expect(subject.results.none?(&:reblog?)).to be true
        end
      end
    end

    context 'when accessed anonymously' do
      let(:current_account) { nil }
      let(:direct_status) { nil }

      it 'returns only public statuses' do
        expect(subject.results.pluck(:visibility).uniq).to match_array %w(unlisted public)
      end

      it 'returns public replies' do
        expect(subject.results.pluck(:in_reply_to_id)).to_not be_empty
      end

      it 'returns public reblogs' do
        expect(subject.results.pluck(:reblog_of_id)).to_not be_empty
      end

      it_behaves_like 'filter params'
    end

    context 'when accessed with a blocked account' do
      let(:current_account) { Fabricate(:account) }

      before do
        account.block!(current_account)
      end

      it 'returns nothing' do
        expect(subject.results.to_a).to be_empty
      end
    end

    context 'when accessed by self' do
      let(:current_account) { account }

      it 'returns everything' do
        expect(subject.results.pluck(:visibility).uniq).to match_array %w(direct private unlisted public)
      end

      it 'returns replies' do
        expect(subject.results.pluck(:in_reply_to_id)).to_not be_empty
      end

      it 'returns reblogs' do
        expect(subject.results.pluck(:reblog_of_id)).to_not be_empty
      end

      it_behaves_like 'filter params'
    end

    context 'when accessed by a follower' do
      let(:current_account) { Fabricate(:account) }

      before do
        current_account.follow!(account)
      end

      it 'returns private statuses' do
        expect(subject.results.pluck(:visibility).uniq).to match_array %w(private unlisted public)
      end

      it 'returns replies' do
        expect(subject.results.pluck(:in_reply_to_id)).to_not be_empty
      end

      it 'returns reblogs' do
        expect(subject.results.pluck(:reblog_of_id)).to_not be_empty
      end

      context 'when there is a direct status mentioning the non-follower' do
        let!(:direct_status) { status_with_mention!(:direct, current_account) }

        it 'returns the direct status' do
          expect(subject.results.pluck(:id)).to include(direct_status.id)
        end
      end

      it_behaves_like 'filter params'
    end

    context 'when accessed by a non-follower' do
      let(:current_account) { Fabricate(:account) }

      it 'returns only public statuses' do
        expect(subject.results.pluck(:visibility).uniq).to match_array %w(unlisted public)
      end

      it 'returns public replies' do
        expect(subject.results.pluck(:in_reply_to_id)).to_not be_empty
      end

      it 'returns public reblogs' do
        expect(subject.results.pluck(:reblog_of_id)).to_not be_empty
      end

      context 'when there is a private status mentioning the non-follower' do
        let!(:private_status) { status_with_mention!(:private, current_account) }

        it 'returns the private status' do
          expect(subject.results.pluck(:id)).to include(private_status.id)
        end
      end

      context 'when blocking a reblogged account' do
        let(:reblog) { status_with_reblog!('public') }

        before do
          current_account.block!(reblog.reblog.account)
        end

        it 'does not return reblog of blocked account' do
          expect(subject.results.pluck(:id)).to_not include(reblog.id)
        end
      end

      context 'when muting a reblogged account' do
        let(:reblog) { status_with_reblog!('public') }

        before do
          current_account.mute!(reblog.reblog.account)
        end

        it 'does not return reblog of muted account' do
          expect(subject.results.pluck(:id)).to_not include(reblog.id)
        end
      end

      context 'when blocked by a reblogged account' do
        let(:reblog) { status_with_reblog!('public') }

        before do
          reblog.reblog.account.block!(current_account)
        end

        it 'does not return reblog of blocked-by account' do
          expect(subject.results.pluck(:id)).to_not include(reblog.id)
        end
      end

      it_behaves_like 'filter params'
    end
  end
end
