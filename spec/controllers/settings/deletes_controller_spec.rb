# frozen_string_literal: true

require 'rails_helper'

describe Settings::DeletesController do
  render_views

  describe 'GET #show' do
    context 'when signed in' do
      let(:user) { Fabricate(:user) }

      before do
        sign_in user, scope: :user
        get :show
      end

      it 'renders confirmation page' do
        expect(response).to have_http_status(200)
      end

      it 'returns private cache control headers' do
        expect(response.headers['Cache-Control']).to include('private, no-store')
      end

      context 'when suspended' do
        let(:user) { Fabricate(:user, account_attributes: { suspended_at: Time.now.utc }) }

        it 'returns http forbidden' do
          expect(response).to have_http_status(403)
        end

        it 'returns private cache control headers' do
          expect(response.headers['Cache-Control']).to include('private, no-store')
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        get :show
        expect(response).to redirect_to '/auth/sign_in'
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
        before do
          delete :destroy, params: { form_delete_confirmation: { password: 'petsmoldoggos' } }
        end

        it 'redirects to sign in page' do
          expect(response).to redirect_to '/auth/sign_in'
        end

        it 'removes user record' do
          expect(User.find_by(id: user.id)).to be_nil
        end

        it 'marks account as suspended' do
          expect(user.account.reload).to be_suspended
        end

        it 'does not create an email block' do
          expect(CanonicalEmailBlock.block?(user.email)).to be false
        end

        context 'when suspended' do
          let(:user) { Fabricate(:user, account_attributes: { suspended_at: Time.now.utc }) }

          it 'returns http forbidden' do
            expect(response).to have_http_status(403)
          end
        end
      end

      context 'with incorrect password' do
        before do
          delete :destroy, params: { form_delete_confirmation: { password: 'blaze420' } }
        end

        it 'redirects back to confirmation page' do
          expect(response).to redirect_to settings_delete_path
        end
      end
    end

    context 'when not signed in' do
      it 'redirects' do
        delete :destroy
        expect(response).to redirect_to '/auth/sign_in'
      end
    end
  end
end
