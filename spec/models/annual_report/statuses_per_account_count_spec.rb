# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::StatusesPerAccountCount do
  describe '.refresh' do
    subject { described_class.refresh(year) }

    let(:year) { Time.zone.now.year }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'does not build a status count record' do
        expect { subject }
          .to not_change(described_class, :count).from(0)
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      before do
        Fabricate :status
        Fabricate.times 2, :status, account: account
      end

      it 'builds a status count record' do
        expect { subject }
          .to change(described_class, :count).by(2)
        expect(described_class.where(account_id: account).first)
          .to have_attributes(statuses_count: 2)
      end
    end
  end
end
