# frozen_string_literal: true

require 'rails_helper'

describe Settings::DeletesController do
  render_views

  describe 'GET #show' do
    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before do
        sign_in user, scope: :user
      end

      it 'renders confirmation page with private cache control headers', :aggregate_failures do
        get :show

        expect(response)
          .to have_http_status(200)
          .and render_template(:show)
          .and have_attributes(
            headers: hash_including(
              'Cache-Control' => include('private, no-store')
            )
          )
      end

      context 'when suspended' do
        let(:user) { Fabricate(:user, account_attributes: { suspended_at: Time.now.utc }) }

        it 'returns http forbidden with private cache control headers', :aggregate_failures do
          get :show

          expect(response)
            .to have_http_status(403)
            .and have_attributes(
              headers: hash_including(
                'Cache-Control' => include('private, no-store')
              )
            )
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        get :show

        expect(response)
          .to redirect_to '/auth/sign_in'
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when signed in' do
      let(:user) { Fabricate(:user, password: 'petsmoldoggos') }

      before do
        sign_in user, scope: :user
      end

      context 'with correct password' do
        it 'removes user record and redirects', :aggregate_failures do
          delete :destroy, params: { form_delete_confirmation: { password: 'petsmoldoggos' } }

          expect(response)
            .to redirect_to '/auth/sign_in'

          expect(User.find_by(id: user.id))
            .to be_nil
          expect(user.account.reload)
            .to be_suspended
          expect(CanonicalEmailBlock.block?(user.email))
            .to be false
        end

        context 'when suspended' do
          let(:user) { Fabricate(:user, account_attributes: { suspended_at: Time.now.utc }) }

          it 'returns http forbidden' do
            delete :destroy, params: { form_delete_confirmation: { password: 'petsmoldoggos' } }

            expect(response)
              .to have_http_status(403)
          end
        end
      end

      context 'with blank encrypted password' do
        let(:user) { Fabricate(:user, encrypted_password: '') }

        it 'removes user record and redirects', :aggregate_failures do
          delete :destroy, params: { form_delete_confirmation: { username: user.account.username } }

          expect(response)
            .to redirect_to '/auth/sign_in'

          expect(User.find_by(id: user.id))
            .to be_nil
          expect(user.account.reload)
            .to be_suspended
          expect(CanonicalEmailBlock.block?(user.email))
            .to be false
        end
      end

      context 'with incorrect password' do
        it 'redirects back to confirmation page' do
          delete :destroy, params: { form_delete_confirmation: { password: 'blaze420' } }

          expect(response)
            .to redirect_to settings_delete_path
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        delete :destroy

        expect(response)
          .to redirect_to '/auth/sign_in'
      end
    end
  end
end
