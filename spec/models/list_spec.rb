# frozen_string_literal: true

require 'rails_helper'

RSpec.describe List do
  describe 'Validations' do
    subject { Fabricate.build :list }

    it { is_expected.to validate_length_of(:title).is_at_most(described_class::TITLE_LENGTH_LIMIT) }
    it { is_expected.to validate_presence_of(:title) }

    context 'when account has hit max list limit' do
      let(:account) { Fabricate :account }

      before do
        stub_const 'List::PER_ACCOUNT_LIMIT', 1

        Fabricate(:list, account: account)
      end

      context 'when creating a new list' do
        it { is_expected.to_not allow_value(account).for(:account).against(:base).with_message(I18n.t('lists.errors.limit')) }
      end

      context 'when updating an existing list' do
        before { subject.save(validate: false) }

        it { is_expected.to allow_value(account).for(:account).against(:base) }
      end
    end
  end

  describe 'Scopes' do
    describe '.with_list_account' do
      let(:alice) { Fabricate :account }
      let(:bob) { Fabricate :account }
      let(:list) { Fabricate :list }
      let(:other_list) { Fabricate :list }

      before do
        Fabricate :follow, account: list.account, target_account: alice
        Fabricate :follow, account: other_list.account, target_account: bob
        Fabricate :list_account, list: list, account: alice
        Fabricate :list_account, list: other_list, account: bob
      end

      it 'returns lists connected to the account' do
        expect(described_class.with_list_account(alice))
          .to include(list)
          .and not_include(other_list)
      end
    end
  end
end
