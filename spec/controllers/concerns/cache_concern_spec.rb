# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CacheConcern, type: :controller do
  controller(ApplicationController) do
    include CacheConcern

    def empty_array
      render plain: cache_collection([], Status).size
    end

    def empty_relation
      render plain: cache_collection(Status.none, Status).size
    end
  end

  before do
    routes.draw do
      get  'empty_array' => 'anonymous#empty_array'
      post 'empty_relation' => 'anonymous#empty_relation'
    end
  end

  describe '#cache_collection' do
    context 'given an empty array' do
      it 'returns an empty array' do
        get :empty_array
        expect(response.body).to eq '0'
      end
    end

    context 'given an empty relation' do
      it 'returns an empty array' do
        get :empty_relation
        expect(response.body).to eq '0'
      end
    end
  end
end
