# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreloadingConcern do
  controller(ApplicationController) do
    include PreloadingConcern

    def empty_array
      render plain: preload_collection([], Status).size
    end

    def empty_relation
      render plain: preload_collection(Status.none, Status).size
    end

    def account_statuses_favourites
      render plain: preload_collection(Status.where(account_id: params[:id]), Status).map(&:favourites_count)
    end
  end

  before do
    routes.draw do
      get 'empty_array' => 'anonymous#empty_array'
      get 'empty_relation' => 'anonymous#empty_relation'
      get 'account_statuses_favourites' => 'anonymous#account_statuses_favourites'
    end
  end

  describe '#preload_collection' do
    context 'when given an empty array' do
      it 'returns an empty array' do
        get :empty_array
        expect(response.body).to eq '0'
      end
    end

    context 'when given an empty relation' do
      it 'returns an empty array' do
        get :empty_relation
        expect(response.body).to eq '0'
      end
    end

    context 'when given a collection of statuses' do
      let!(:account) { Fabricate(:account) }
      let!(:status)  { Fabricate(:status, account: account) }

      it 'correctly updates with new interactions' do
        get :account_statuses_favourites, params: { id: account.id }
        expect(response.body).to eq '[0]'

        FavouriteService.new.call(account, status)

        get :account_statuses_favourites, params: { id: account.id }
        expect(response.body).to eq '[1]'
      end
    end
  end
end
