require 'rails_helper'

describe Settings::IdentityProofsController do
  render_views

  let(:user) { Fabricate(:user) }
  let(:valid_token) { '1'*66 }
  let(:kbname) { 'kbuser' }
  let(:provider) { 'Keybase' }
  let(:findable_id) { Faker::Number.number(5) }
  let(:unfindable_id) { Faker::Number.number(5) }
  let(:postable_params) do
    { account_identity_proof: {provider: provider, provider_username: kbname, token: valid_token} }
  end
  let(:putable_params) do
    { id: findable_id, account_identity_proof: {provider: provider, provider_username: kbname, token: valid_token} }
  end

  before do
    sign_in user, scope: :user
  end

  describe 'new proof creation' do
    context 'GET #new with no existing proofs' do
      it 'gets an empty form' do
        get :new

        expect(response.body).to match /<h2>.*Identity Proofs/im
        expect(response.body).to match /<label.*>Provider<\/label>/im
        expect(response.body).to match /<label.*>Provider username<\/label>/im
        expect(response.body).to match /<label.*>Token<\/label>/im
      end

      it 'shows the helpful explanation' do
        get :new
        expect(response.body).to match I18n.t('account_identity_proofs.new_explanation')
      end
    end

    context 'POST #create' do
      context 'when saving works' do
        before do
          allow(KeybaseProofWorker).to receive(:perform_in)
          allow_any_instance_of(AccountIdentityProof).to receive(:save_if_valid_remotely) { true }
        end

        it 'serializes a KeybaseProofWorker' do
          expect(KeybaseProofWorker).to receive(:perform_in)
          post :create, params: postable_params
        end

        it 'flashes success' do
          post :create, params: postable_params
          expect(flash[:info]).to eq I18n.t('account_identity_proofs.update.success', provider: 'Keybase')
        end

        it 'redirects to index' do
          post :create, params: postable_params
          expect(response).to redirect_to(settings_identity_proofs_url)
        end
      end

      context 'when saving fails' do
        before do
          allow_any_instance_of(AccountIdentityProof).to receive(:save_if_valid_remotely) { false }
        end

        it 'renders :new' do
          post :create, params: postable_params
          expect(response).to render_template(:new)
        end

        it 'does not render empty fields' do
          post :create, params: postable_params
          expect(response.body).to match /<textarea.*account_identity_proof\[token\].*#{Regexp.quote(valid_token)}/m
        end
      end

      context 'it can also do an update if the provider and username match' do
        before do
          allow(KeybaseProofWorker).to receive(:perform_in)
          Fabricate(:account_identity_proof, account: user.account, provider: provider, provider_username: kbname)
        end

        it 'calls save_if_valid_remotely with the new token' do
          expect_any_instance_of(AccountIdentityProof).to receive(:save_if_valid_remotely) do |proof|
            expect(proof.token).to eq valid_token
          end
          post :create, params: postable_params
        end
      end
    end
  end

  describe 'GET #index' do
    context 'with no existing proofs' do
      it 'redirects to new' do
        get :index
        expect(response).to redirect_to new_settings_identity_proof_url
      end
    end
    context 'with two proofs' do
      before do
        @proof1 = Fabricate(:account_identity_proof, account: user.account)
        @proof2 = Fabricate(:account_identity_proof, account: user.account)
      end

      it 'has the first proof token on the page' do
        get :index
        expect(response.body).to match /#{Regexp.quote(@proof1.token)}/
      end

      it 'has the second proof token on the page' do
        get :index
        expect(response.body).to match /#{Regexp.quote(@proof2.token)}/
      end
    end
  end

  describe 'PUT #update' do
    context 'with an unfindable id' do
      let(:unfindable_params) do
        putable_params.tap { |params| params[:id] = unfindable_id }
      end

      it '404s' do
        put :update, params: unfindable_params
        expect(response).to have_http_status(:not_found)
      end
    end
    context 'with two proofs' do
      before do
        @proof1 = Fabricate(:account_identity_proof, account: user.account)
        @proof2 = Fabricate(:account_identity_proof, account: user.account)
      end

      context 'updating one of them' do
        let(:update_params) do
          putable_params.tap { |params| params[:account_identity_proof][:id] = @proof1.id }
        end

        context 'when saving works' do
          before do
            allow(KeybaseProofWorker).to receive(:perform_in)
            allow_any_instance_of(AccountIdentityProof).to receive(:save_if_valid_remotely) { true }
          end

          it 'serializes a KeybaseProofWorker' do
            expect(KeybaseProofWorker).to receive(:perform_in)
            put :update, params: update_params
          end

          it 'flashes success' do
            put :update, params: update_params
            expect(flash[:info]).to eq I18n.t('account_identity_proofs.update.success', provider: 'Keybase')
          end

          it 'redirects to index' do
            put :update, params: update_params
            expect(response).to redirect_to(settings_identity_proofs_url)
          end
        end

        context 'when saving fails' do
          before do
            allow_any_instance_of(AccountIdentityProof).to receive(:save_if_valid_remotely) { false }
          end

          it 'renders :show' do
            put :update, params: update_params
            expect(response).to render_template(:show)
          end

          it 'renders the token field with the new, unsaved token value' do
            put :update, params: update_params
            expect(response.body).to match /<textarea.*account_identity_proof\[token\].*#{Regexp.quote(valid_token)}/m
          end
        end
      end
    end
  end
end
