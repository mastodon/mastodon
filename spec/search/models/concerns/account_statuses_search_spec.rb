# frozen_string_literal: true

require 'rails_helper'

describe AccountStatusesSearch do
  let(:account) { Fabricate(:account, indexable: indexable) }
  # indexable must be true in order for the statuses to end up in the index
  let(:indexable) { true }

  before do
    allow(Chewy).to receive(:enabled?).and_return(true)

    PublicStatusesIndex.delete
    PublicStatusesIndex.create
  end

  after do
    PublicStatusesIndex.delete
  end

  describe '#add_to_public_statuses_index!' do
    it 'adds the statuses to the PublicStatusesIndex' do
      expect(PublicStatusesIndex.filter(term: { account_id: account.id }).count).to eq(0)

      Fabricate(:status, account: account, text: 'status 1', visibility: :public)
      Fabricate(:status, account: account, text: 'status 2', visibility: :public)
      account.add_to_public_statuses_index!

      expect(PublicStatusesIndex.filter(term: { account_id: account.id }).count).to eq(2)
    end
  end

  describe '#remove_from_public_statuses_index!' do
    let(:status_one) { Fabricate(:status, account: account, text: 'status 1') }
    let(:status_two) { Fabricate(:status, account: account, text: 'status 2') }

    before do
      PublicStatusesIndex.import([status_one, status_two])
    end

    it 'removes the statuses from the PublicStatusesIndex' do
      expect(PublicStatusesIndex.filter(term: { account_id: account.id }).count).to eq(2)

      account.remove_from_public_statuses_index!

      expect(PublicStatusesIndex.filter(term: { account_id: account.id }).count).to eq(0)
    end
  end
end
