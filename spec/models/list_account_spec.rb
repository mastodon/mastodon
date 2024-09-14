# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListAccount do
  describe 'Callbacks to set follows' do
    context 'when list owner follows account' do
      let!(:follow) { Fabricate :follow }
      let(:list) { Fabricate :list, account: follow.account }

      it 'finds and sets the follow with the list account' do
        list_account = described_class.create list: list, account: follow.target_account
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
        list_account = described_class.create list: list, account: follow_request.target_account
        expect(list_account)
          .to have_attributes(
            follow: be_nil,
            follow_request: eq(follow_request)
          )
      end
    end

    context 'when list owner is the account' do
      let(:list) { Fabricate :list  }

      it 'does not set follow or follow request' do
        list_account = described_class.create list: list, account: list.account
        expect(list_account)
          .to have_attributes(
            follow: be_nil,
            follow_request: be_nil
          )
      end
    end
  end
end
