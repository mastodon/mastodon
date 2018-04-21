# frozen_string_literal: true

require 'rails_helper'

describe Auth::PasswordsController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe 'GET #new' do
    it 'returns http success' do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      get :new
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #edit' do
    let(:user) { Fabricate(:user) }

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      @token = user.send_reset_password_instructions
    end

    context 'with valid reset_password_token' do
      it 'returns http success' do
        get :edit, params: { reset_password_token: @token }
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid reset_password_token' do
      it 'redirects to #new' do
        get :edit, params: { reset_password_token: 'some_invalid_value' }
        expect(response).to redirect_to subject.new_password_path(subject.send(:resource_name))
      end
    end
  end
end
