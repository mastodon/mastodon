# frozen_string_literal: true

require 'rails_helper'

describe Admin::ActionLogsController, type: :controller do
  describe 'GET #index' do
    it 'returns 200' do
      sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin'))
      get :index, params: { page: 1 }

      expect(response).to have_http_status(200)
    end
  end
end
