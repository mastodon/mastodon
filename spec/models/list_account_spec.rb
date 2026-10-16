# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListAccount do
  describe 'Callbacks to set follows' do
    context 'when list owner follows account' do
      let!(:follow) { Fabricate :follow }
      let(:list) { Fabricate :list, account: follow.account }

      it 'finds and sets the follow with the list account' do
        list_account = Fabricate :list_account, list: list, account: follow.target_account
        expect(list_account)
          .to have_attributes(
            follow: eq(follow),
            follow_request: be_nil
          )
      end
    end

    context 'when list owner has a follow request for account' do
      let!(:follow_request) { Fabricate :follow_request }
      let(:list) { Fabricate :list, account: follow_request.account }

      it 'finds and sets the follow request with the list account' do
        list_account = Fabricate :list_account, list: list, account: follow_request.target_account
        expect(list_account)
          .to have_attributes(
            follow: be_nil,
            follow_request: eq(follow_request)
          )
      end
    end

    context 'when list owner is the account' do
      it 'does not set follow or follow request' do
        list_account = Fabricate :list_account
        expect(list_account)
          .to have_attributes(
            follow: be_nil,
            follow_request: be_nil
          )
      end
    end
  end

  describe 'validations' do
    before do
      allow(list_account).to receive(:set_follow)
    end

    context 'when account is not followed' do
      subject(:list_account) do
        Fabricate.build(
          :list_account,
          list: Fabricate(:list),
          account: Fabricate(:account)
        )
      end

      it { is_expected.to_not be_valid }

      it 'adds must_be_following error' do
        list_account.valid?

        expect(list_account.errors[:account_id]).to be_present
      end
    end

    context 'when follow target account does not match account' do
      subject(:list_account) do
        Fabricate.build(
          :list_account,
          list: Fabricate(:list, account: follow.account),
          account: Fabricate(:account),
          follow: follow
        )
      end

      let(:follow) { Fabricate(:follow) }

      it { is_expected.to_not be_valid }

      it 'adds invalid follow error' do
        list_account.valid?

        expect(list_account.errors[:follow]).to be_present
      end
    end

    context 'when follow request target account does not match account' do
      subject(:list_account) do
        Fabricate.build(
          :list_account,
          list: Fabricate(:list, account: follow_request.account),
          account: Fabricate(:account),
          follow_request: follow_request
        )
      end

      let(:follow_request) { Fabricate(:follow_request) }

      it { is_expected.to_not be_valid }

      it 'adds invalid follow request error' do
        list_account.valid?

        expect(list_account.errors[:follow_request]).to be_present
      end
    end
  end
end
