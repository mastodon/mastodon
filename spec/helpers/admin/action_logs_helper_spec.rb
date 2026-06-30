# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ActionLogsHelper do
  before { sign_in Fabricate(:admin_user) }

  describe 'with Tags' do
    let(:tag) { Fabricate(:tag, name: '#supertag') }
    let(:account) { Fabricate(:account) }
    let!(:log) { Fabricate(:action_log, target: tag, account: account, usable: false, listable: true) }

    describe '#permutation_of_key' do
      it 'returns different permutations for all different states' do
        expect(helper.permutation_of_key(log, :usable)).to eq(:not_usable)
        expect(helper.permutation_of_key(log, :trendable)).to be_nil
        expect(helper.permutation_of_key(log, :listable)).to eq(:listable)
      end
    end

    describe '#chain_multiple_translations' do
      it 'returns translation keys for all different states' do
        expect(helper.chain_multiple_translations(log)).to eq('Cannot be used; Can be suggested')
      end
    end
  end
end
