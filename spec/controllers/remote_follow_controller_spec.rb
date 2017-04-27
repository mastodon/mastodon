# frozen_string_literal: true

require 'rails_helper'

describe RemoteFollowController do
  render_views

  describe '#new' do
    it 'returns a success' do
      account = Fabricate(:account)
      get :new, params: { account_username: account.to_param }

      expect(response).to have_http_status(:success)
    end
  end
end
