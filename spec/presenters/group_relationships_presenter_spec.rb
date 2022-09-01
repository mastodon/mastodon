# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupRelationshipsPresenter do
  describe '.initialize' do
    before do
      allow(Group).to receive(:member_map).with(group_ids, current_account_id).and_return(default_map)
      allow(Group).to receive(:requested_map).with(group_ids, current_account_id).and_return(default_map)
    end

    let(:presenter)          { GroupRelationshipsPresenter.new(group_ids, current_account_id, **options) }
    let(:current_account_id) { Fabricate(:account).id }
    let(:group_ids)          { [Fabricate(:group).id] }
    let(:default_map)        { { 1 => true } }

    context 'options are not set' do
      let(:options) { {} }

      it 'sets default maps' do
        expect(presenter.member).to          eq default_map
        expect(presenter.requested).to       eq default_map
      end
    end

    context 'options[:member_map] is set' do
      let(:options) { { member_map: { 2 => { role: :user } } } }

      it 'sets @member merged with default_map and options[:member_map]' do
        expect(presenter.member).to eq default_map.merge(options[:member_map])
      end
    end

    context 'options[:requested_map] is set' do
      let(:options) { { requested_map: { 6 => true } } }

      it 'sets @requested merged with default_map and options[:requested_map]' do
        expect(presenter.requested).to eq default_map.merge(options[:requested_map])
      end
    end
  end
end
