# frozen_string_literal: true

require 'rails_helper'

describe 'Severed relationships page' do
  include RoutingHelper

  describe 'GET severed_relationships#index' do
    let(:user) { Fabricate(:user) }

    before do
      sign_in user

      Fabricate(:severed_relationship, local_account: user.account)
    end

    it 'returns http success' do
      get severed_relationships_path

      expect(response).to have_http_status(200)
    end
  end
end
