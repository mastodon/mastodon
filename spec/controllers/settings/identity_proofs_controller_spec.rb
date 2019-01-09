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

  before do
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
          allow(KeybaseProofWorker).to receive(:perform_in)
          allow_any_instance_of(AccountIdentityProof).to receive(:save_if_valid_remotely) { true }
          allow_any_instance_of(AccountIdentityProof).to receive(:success_redirect) { root_url }
        end

        it 'serializes a KeybaseProofWorker' do
          expect(KeybaseProofWorker).to receive(:perform_in)
          post :create, params: postable_params
        end

        it 'delegates redirection to the proof provider' do
          expect_any_instance_of(AccountIdentityProof).to receive(:success_redirect)
          post :create, params: postable_params
          expect(response).to redirect_to root_url
        end
      end

      context 'when saving fails' do
        before do
          allow_any_instance_of(AccountIdentityProof).to receive(:save_if_valid_remotely) { false }
        end

        it 'redirects to :index' do
          post :create, params: postable_params
          expect(response).to redirect_to settings_identity_proofs_path
        end

        it 'flashes a helpful message' do
          post :create, params: postable_params
          expect(flash[:alert]).to eq I18n.t('account_identity_proofs.save.failed', provider: 'Keybase')
        end
      end

      context 'it can also do an update if the provider and username match an existing proof' do
        before do
          allow(KeybaseProofWorker).to receive(:perform_in)
          Fabricate(:account_identity_proof, account: user.account, provider: provider, provider_username: kbname)
          allow_any_instance_of(AccountIdentityProof).to receive(:success_redirect) { root_url }
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
      it 'shows the helpful explanation' do
        get :index
        expect(response.body).to match I18n.t('account_identity_proofs.new_explanation')
      end
    end

    context 'with two proofs' do
      before do
        @proof1 = Fabricate(:account_identity_proof, account: user.account)
        @proof2 = Fabricate(:account_identity_proof, account: user.account)
        allow_any_instance_of(AccountIdentityProof).to receive(:remote_profile_pic_url) { }
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
