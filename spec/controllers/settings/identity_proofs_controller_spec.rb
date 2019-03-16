require 'rails_helper'

describe Settings::IdentityProofsController do
  render_views

  let(:user) { Fabricate(:user) }
  let(:valid_token) { '1'*66 }
  let(:kbname) { 'kbuser' }
  let(:provider) { 'keybase' }
  let(:findable_id) { Faker::Number.number(5) }
  let(:unfindable_id) { Faker::Number.number(5) }
  let(:postable_params) do
    { account_identity_proof: { provider: provider, provider_username: kbname, token: valid_token } }
  end

  before do
    allow_any_instance_of(ProofProvider::Keybase::Verifier).to receive(:status) { { 'proof_valid' => true, 'proof_live' => true } }
    sign_in user, scope: :user
  end

  describe 'new proof creation' do
    context 'GET #new with no existing proofs' do
      it 'redirects to :index' do
        get :new
        expect(response).to redirect_to settings_identity_proofs_path
      end
    end

    context 'POST #create' do
      context 'when saving works' do
        before do
          allow(ProofProvider::Keybase::Worker).to receive(:perform_async)
          allow_any_instance_of(ProofProvider::Keybase::Verifier).to receive(:valid?) { true }
          allow_any_instance_of(AccountIdentityProof).to receive(:on_success_path) { root_url }
        end

        it 'serializes a ProofProvider::Keybase::Worker' do
          expect(ProofProvider::Keybase::Worker).to receive(:perform_async)
          post :create, params: postable_params
        end

        it 'delegates redirection to the proof provider' do
          expect_any_instance_of(AccountIdentityProof).to receive(:on_success_path)
          post :create, params: postable_params
          expect(response).to redirect_to root_url
        end
      end

      context 'when saving fails' do
        before do
          allow_any_instance_of(ProofProvider::Keybase::Verifier).to receive(:valid?) { false }
        end

        it 'redirects to :index' do
          post :create, params: postable_params
          expect(response).to redirect_to settings_identity_proofs_path
        end

        it 'flashes a helpful message' do
          post :create, params: postable_params
          expect(flash[:alert]).to eq I18n.t('identity_proofs.errors.failed', provider: 'Keybase')
        end
      end

      context 'it can also do an update if the provider and username match an existing proof' do
        before do
          allow_any_instance_of(ProofProvider::Keybase::Verifier).to receive(:valid?) { true }
          allow(ProofProvider::Keybase::Worker).to receive(:perform_async)
          Fabricate(:account_identity_proof, account: user.account, provider: provider, provider_username: kbname)
          allow_any_instance_of(AccountIdentityProof).to receive(:on_success_path) { root_url }
        end

        it 'calls update with the new token' do
          expect_any_instance_of(AccountIdentityProof).to receive(:save) do |proof|
            expect(proof.token).to eq valid_token
          end

          post :create, params: postable_params
        end
      end
    end
  end

  describe 'GET #index' do
    context 'with no existing proofs' do
      it 'shows the helpful explanation' do
        get :index
        expect(response.body).to match I18n.t('identity_proofs.explanation_html')
      end
    end

    context 'with two proofs' do
      before do
        allow_any_instance_of(ProofProvider::Keybase::Verifier).to receive(:valid?) { true }
        @proof1 = Fabricate(:account_identity_proof, account: user.account)
        @proof2 = Fabricate(:account_identity_proof, account: user.account)
        allow_any_instance_of(AccountIdentityProof).to receive(:badge) { double(avatar_url: '', profile_url: '', proof_url: '') }
        allow_any_instance_of(AccountIdentityProof).to receive(:refresh!) { }
      end

      it 'has the first proof username on the page' do
        get :index
        expect(response.body).to match /#{Regexp.quote(@proof1.provider_username)}/
      end

      it 'has the second proof username on the page' do
        get :index
        expect(response.body).to match /#{Regexp.quote(@proof2.provider_username)}/
      end
    end
  end
end
