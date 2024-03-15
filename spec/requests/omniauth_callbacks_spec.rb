# frozen_string_literal: true

require 'rails_helper'

describe 'OmniAuth callbacks' do
  shared_examples 'omniauth provider callbacks' do |provider|
    subject { post send :"user_#{provider}_omniauth_callback_path" }

    context 'with full information in response' do
      before do
        mock_omniauth(provider, {
          provider: provider.to_s,
          uid: '123',
          info: {
            verified: 'true',
            email: 'user@host.example',
          },
        })
      end

      context 'without a matching user' do
        it 'creates a user and an identity and redirects to root path' do
          expect { subject }
            .to change(User, :count)
            .by(1)
            .and change(Identity, :count)
            .by(1)
            .and change(LoginActivity, :count)
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

        context 'when ALLOW_UNSAFE_AUTH_PROVIDER_REATTACH is set to true' do
          around do |example|
            ClimateControl.modify ALLOW_UNSAFE_AUTH_PROVIDER_REATTACH: 'true' do
              example.run
            end
          end

          it 'matches the existing user, creates an identity, and redirects to root path' do
            expect { subject }
              .to not_change(User, :count)
              .and change(Identity, :count)
              .by(1)
              .and change(LoginActivity, :count)
              .by(1)

            expect(Identity.find_by(user: User.last).uid).to eq('123')
            expect(response).to redirect_to(root_path)
          end
        end

        context 'when ALLOW_UNSAFE_AUTH_PROVIDER_REATTACH is not set to true' do
          it 'does not match the existing user or create an identity, and redirects to login page' do
            expect { subject }
              .to not_change(User, :count)
              .and not_change(Identity, :count)
              .and not_change(LoginActivity, :count)

            expect(response).to redirect_to(new_user_session_url)
          end
        end
      end

      context 'with a matching user and a matching identity' do
        before do
          user = Fabricate(:user, email: 'user@host.example')
          Fabricate(:identity, user: user, uid: '123', provider: provider)
        end

        it 'matches the existing records and redirects to root path' do
          expect { subject }
            .to not_change(User, :count)
            .and not_change(Identity, :count)
            .and change(LoginActivity, :count)
            .by(1)

          expect(response).to redirect_to(root_path)
        end
      end
    end

    context 'with a response missing email address' do
      before do
        mock_omniauth(provider, {
          provider: provider.to_s,
          uid: '123',
          info: {
            verified: 'true',
          },
        })
      end

      it 'redirects to the auth setup page' do
        expect { subject }
          .to change(User, :count)
          .by(1)
          .and change(Identity, :count)
          .by(1)
          .and change(LoginActivity, :count)
          .by(1)

        expect(response).to redirect_to(auth_setup_path(missing_email: '1'))
      end
    end

    context 'when a user cannot be built' do
      before do
        allow(User).to receive(:find_for_omniauth).and_return(User.new)
      end

      it 'redirects to the new user signup page' do
        expect { subject }
          .to not_change(User, :count)
          .and not_change(Identity, :count)
          .and not_change(LoginActivity, :count)

        expect(response).to redirect_to(new_user_registration_url)
      end
    end
  end

  describe '#openid_connect', if: ENV['OIDC_ENABLED'] == 'true' && ENV['OIDC_SCOPE'].present? do
    include_examples 'omniauth provider callbacks', :openid_connect
  end

  describe '#cas', if: ENV['CAS_ENABLED'] == 'true' do
    include_examples 'omniauth provider callbacks', :cas
  end

  describe '#saml', if: ENV['SAML_ENABLED'] == 'true' do
    include_examples 'omniauth provider callbacks', :saml
  end
end
