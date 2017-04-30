# frozen_string_literal: true

require 'rails_helper'

describe StatusesController do
  render_views

  describe '#show' do
    it 'returns a success' do
      status = Fabricate(:status)
      get :show, params: { account_username: status.account.username, id: status.id }

      expect(response).to have_http_status(:success)
    end
  end
end
