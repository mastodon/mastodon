# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusRelationshipsPresenter do
  describe '.initialize' do
    before do
      allow(Status).to receive(:reblogs_map).with(status_ids, current_account_id).and_return(default_map)
      allow(Status).to receive(:favourites_map).with(status_ids, current_account_id).and_return(default_map)
      allow(Status).to receive(:bookmarks_map).with(status_ids, current_account_id).and_return(default_map)
      allow(Status).to receive(:mutes_map).with(anything, current_account_id).and_return(default_map)
      allow(Status).to receive(:pins_map).with(anything, current_account_id).and_return(default_map)
    end

    let(:presenter)          { StatusRelationshipsPresenter.new(statuses, current_account_id, **options) }
    let(:current_account_id) { Fabricate(:account).id }
    let(:statuses)           { [Fabricate(:status)] }
    let(:status_ids)         { statuses.map(&:id) }
    let(:default_map)        { { 1 => true } }

    context 'options are not set' do
      let(:options) { {} }

      it 'sets default maps' do
        expect(presenter.reblogs_map).to    eq default_map
        expect(presenter.favourites_map).to eq default_map
        expect(presenter.bookmarks_map).to  eq default_map
        expect(presenter.mutes_map).to      eq default_map
        expect(presenter.pins_map).to       eq default_map
      end
    end

    context 'options[:reblogs_map] is set' do
      let(:options) { { reblogs_map: { 2 => true } } }

      it 'sets @reblogs_map merged with default_map and options[:reblogs_map]' do
        expect(presenter.reblogs_map).to eq default_map.merge(options[:reblogs_map])
      end
    end

    context 'options[:favourites_map] is set' do
      let(:options) { { favourites_map: { 3 => true } } }

      it 'sets @favourites_map merged with default_map and options[:favourites_map]' do
        expect(presenter.favourites_map).to eq default_map.merge(options[:favourites_map])
      end
    end

    context 'options[:bookmarks_map] is set' do
      let(:options) { { bookmarks_map: { 4 => true } } }

      it 'sets @bookmarks_map merged with default_map and options[:bookmarks_map]' do
        expect(presenter.bookmarks_map).to eq default_map.merge(options[:bookmarks_map])
      end
    end

    context 'options[:mutes_map] is set' do
      let(:options) { { mutes_map: { 5 => true } } }

      it 'sets @mutes_map merged with default_map and options[:mutes_map]' do
        expect(presenter.mutes_map).to eq default_map.merge(options[:mutes_map])
      end
    end

    context 'options[:pins_map] is set' do
      let(:options) { { pins_map: { 6 => true } } }

      it 'sets @pins_map merged with default_map and options[:pins_map]' do
        expect(presenter.pins_map).to eq default_map.merge(options[:pins_map])
      end
    end
  end
end
