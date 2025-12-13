# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSummary do
  describe 'Scopes' do
    describe '.localized' do
      let(:first) { Fabricate :account }
      let(:last) { Fabricate :account }

      before do
        Fabricate :status, account: first, language: 'en'
        Fabricate :status, account: last, language: 'es'
        described_class.refresh
      end

      it 'returns records in order of language' do
        expect(described_class.localized('en'))
          .to contain_exactly(
            have_attributes(account_id: first.id, language: 'en'),
            have_attributes(account_id: last.id, language: 'es')
          )
      end
    end
  end
end
