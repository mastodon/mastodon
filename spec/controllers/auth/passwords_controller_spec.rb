# frozen_string_literal: true

require 'rails_helper'

describe Auth::PasswordsController, type: :controller do
  describe 'GET #new' do
    it 'returns http success' do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      get :new
      expect(response).to have_http_status(:success)
    end
  end
end
