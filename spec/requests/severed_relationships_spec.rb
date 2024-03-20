# frozen_string_literal: true

require 'rails_helper'

describe 'Severed relationships page' do
  include RoutingHelper

  describe 'GET severed_relationships#index' do
    let(:user) { Fabricate(:user) }
    let(:event) { Fabricate(:account_relationship_severance_event, account: user.account) }

    before do
      sign_in user

      Fabricate.times(3, :severed_relationship, local_account: user.account, relationship_severance_event: event.relationship_severance_event)
    end

    it 'returns http success' do
      get severed_relationships_path

      expect(response).to have_http_status(200)
    end
  end
end
