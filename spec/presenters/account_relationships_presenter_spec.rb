# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountRelationshipsPresenter do
  describe '.initialize' do
    before do
      allow(Account).to receive(:following_map).with(accounts.pluck(:id), current_account_id).and_return(default_map)
      allow(Account).to receive(:followed_by_map).with(accounts.pluck(:id), current_account_id).and_return(default_map)
      allow(Account).to receive(:blocking_map).with(accounts.pluck(:id), current_account_id).and_return(default_map)
      allow(Account).to receive(:muting_map).with(accounts.pluck(:id), current_account_id).and_return(default_map)
      allow(Account).to receive(:requested_map).with(accounts.pluck(:id), current_account_id).and_return(default_map)
      allow(Account).to receive(:requested_by_map).with(accounts.pluck(:id), current_account_id).and_return(default_map)
    end

    let(:presenter)          { described_class.new(accounts, current_account_id, **options) }
    let(:current_account_id) { Fabricate(:account).id }
    let(:accounts)           { [Fabricate(:account)] }
    let(:default_map)        { { accounts[0].id => true } }

    context 'when options are not set' do
      let(:options) { {} }

      it 'sets default maps' do
        expect(presenter).to have_attributes(
          following: default_map,
          followed_by: default_map,
          blocking: default_map,
          muting: default_map,
          requested: default_map,
          domain_blocking: { accounts[0].id => nil }
        )
      end
    end

    context 'with a warm cache' do
      let(:options) { {} }

      before do
        described_class.new(accounts, current_account_id, **options)

        allow(Account).to receive(:following_map).with([], current_account_id).and_return({})
        allow(Account).to receive(:followed_by_map).with([], current_account_id).and_return({})
        allow(Account).to receive(:blocking_map).with([], current_account_id).and_return({})
        allow(Account).to receive(:muting_map).with([], current_account_id).and_return({})
        allow(Account).to receive(:requested_map).with([], current_account_id).and_return({})
        allow(Account).to receive(:requested_by_map).with([], current_account_id).and_return({})
      end

      it 'sets returns expected values' do
        expect(presenter).to have_attributes(
          following: default_map,
          followed_by: default_map,
          blocking: default_map,
          muting: default_map,
          requested: default_map,
          domain_blocking: { accounts[0].id => nil }
        )
      end
    end

    context 'when options[:following_map] is set' do
      let(:options) { { following_map: { 2 => true } } }

      it 'sets @following merged with default_map and options[:following_map]' do
        expect(presenter.following).to eq default_map.merge(options[:following_map])
      end
    end

    context 'when options[:followed_by_map] is set' do
      let(:options) { { followed_by_map: { 3 => true } } }

      it 'sets @followed_by merged with default_map and options[:followed_by_map]' do
        expect(presenter.followed_by).to eq default_map.merge(options[:followed_by_map])
      end
    end

    context 'when options[:blocking_map] is set' do
      let(:options) { { blocking_map: { 4 => true } } }

      it 'sets @blocking merged with default_map and options[:blocking_map]' do
        expect(presenter.blocking).to eq default_map.merge(options[:blocking_map])
      end
    end

    context 'when options[:muting_map] is set' do
      let(:options) { { muting_map: { 5 => true } } }

      it 'sets @muting merged with default_map and options[:muting_map]' do
        expect(presenter.muting).to eq default_map.merge(options[:muting_map])
      end
    end

    context 'when options[:requested_map] is set' do
      let(:options) { { requested_map: { 6 => true } } }

      it 'sets @requested merged with default_map and options[:requested_map]' do
        expect(presenter.requested).to eq default_map.merge(options[:requested_map])
      end
    end

    context 'when options[:requested_by_map] is set' do
      let(:options) { { requested_by_map: { 6 => true } } }

      it 'sets @requested merged with default_map and options[:requested_by_map]' do
        expect(presenter.requested_by).to eq default_map.merge(options[:requested_by_map])
      end
    end

    context 'when options[:domain_blocking_map] is set' do
      let(:options) { { domain_blocking_map: { 7 => true } } }

      it 'sets @domain_blocking merged with default_map and options[:domain_blocking_map]' do
        expect(presenter.domain_blocking).to eq({ accounts[0].id => nil }.merge(options[:domain_blocking_map]))
      end
    end
  end
end
