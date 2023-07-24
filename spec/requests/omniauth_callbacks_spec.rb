# frozen_string_literal: true

require 'rails_helper'

describe 'OmniAuth callbacks' do
  describe '#openid_connect', if: ENV['OIDC_ENABLED'] == 'true' && ENV['OIDC_SCOPE'].present? do
    context 'without a matching user' do
      it 'creates a user and an identity and redirects to root path' do
        expect { post user_openid_connect_omniauth_callback_path }
          .to change(User, :count)
          .by(1)
          .and change(Identity, :count)
          .by(1)
        expect(User.last.email).to eq('user@host.example')
        expect(Identity.find_by(user: User.last).uid).to eq('123')
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with a matching user and no matching identity' do
      before do
        Fabricate(:user, email: 'user@host.example')
      end

      it 'matches the existing user, creates an identity, and redirects to root path' do
        expect { post user_openid_connect_omniauth_callback_path }
          .to not_change(User, :count)
          .and change(Identity, :count).by(1)

        expect(Identity.find_by(user: User.last).uid).to eq('123')
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with a matching user and a matching identity' do
      before do
        user = Fabricate(:user, email: 'user@host.example')
        Fabricate(:identity, user: user, uid: '123', provider: :openid_connect)
      end

      it 'matches the existing records and redirects to root path' do
        expect { post user_openid_connect_omniauth_callback_path }
          .to not_change(User, :count)
          .and not_change(Identity, :count)

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
