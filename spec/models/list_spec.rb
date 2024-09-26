# frozen_string_literal: true

require 'rails_helper'

RSpec.describe List do
  describe 'Validations' do
    subject { Fabricate.build :list }

    it { is_expected.to validate_presence_of(:title) }

    context 'when account has hit max list limit' do
      let(:account) { Fabricate :account }

      before { stub_const 'List::PER_ACCOUNT_LIMIT', 0 }

      context 'when creating a new list' do
        it { is_expected.to_not allow_value(account).for(:account).against(:base).with_message(I18n.t('lists.errors.limit')) }
      end

      context 'when updating an existing list' do
        before { subject.save(validate: false) }

        it { is_expected.to allow_value(account).for(:account).against(:base) }
      end
    end
  end
end
