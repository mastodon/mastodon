# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuotePolicy do
  subject { described_class }

  let(:account) { Fabricate(:account) }

  permissions :revoke? do
    context 'when quote matches the revoking account' do
      let(:quote) { Fabricate.build :quote, quoted_account_id: account.id }

      it { is_expected.to permit(account, quote) }
    end

    context 'when quote does not match the revoking account' do
      let(:quote) { Fabricate.build :quote, quoted_account_id: Fabricate(:account).id }

      it { is_expected.to_not permit(account, quote) }
    end

    context 'when quote does not have quoted account id' do
      let(:quote) { Fabricate.build :quote }

      it { is_expected.to_not permit(account, quote) }
    end
  end
end
