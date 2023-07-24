# frozen_string_literal: true

require 'rails_helper'

describe 'OmniAuth callbacks' do
  describe '#openid_connect', if: ENV['OIDC_ENABLED'] == 'true' && ENV['OIDC_SCOPE'].present? do
    context 'with a user and an identify' do
      before do
        user = Fabricate(:user, email: 'user@host.example')
        Fabricate(:identity, user: user, uid: '123')
      end

      it 'redirects to root path' do
        post user_openid_connect_omniauth_callback_path

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
