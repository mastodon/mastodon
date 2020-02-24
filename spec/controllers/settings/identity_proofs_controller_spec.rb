require 'rails_helper'

describe Settings::IdentityProofsController do
  include RoutingHelper
  render_views

  let(:user) { Fabricate(:user) }
  let(:valid_token) { '1'*66 }
  let(:kbname) { 'kbuser' }
  let(:provider) { 'keybase' }
  let(:findable_id) { Faker::Number.number(5) }
  let(:unfindable_id) { Faker::Number.number(5) }
  let(:new_proof_params) do
    { provider: provider, provider_username: kbname, token: valid_token, username: user.account.username }
  end
  let(:status_text) { "i just proved that i am also #{kbname} on #{provider}." }
  let(:status_posting_params) do
    { post_status: '0', status_text: status_text }
  end
  let(:postable_params) do
    { account_identity_proof: new_proof_params.merge(status_posting_params) }
  end

  before do
    allow_any_instance_of(ProofProvider::Keybase::Verifier).to receive(:status) { { 'proof_valid' => true, 'proof_live' => true } }
    sign_in user, scope: :user
  end

  describe 'new proof creation' do
    context 'GET #new' do
      before do
        allow_any_instance_of(ProofProvider::Keybase::Badge).to receive(:avatar_url) { full_pack_url('media/images/void.png') }
      end

      context 'with all of the correct params' do
        it 'renders the template' do
          get :new, params: new_proof_params
          expect(response).to render_template(:new)
        end
      end

      context 'without any params' do
        it 'redirects to :index' do
          get :new, params: {}
          expect(response).to redirect_to settings_identity_proofs_path
        end
      end

      context 'with params to prove a different, not logged-in user' do
        let(:wrong_user_params) { new_proof_params.merge(username: 'someone_else') }

        it 'shows a helpful alert' do
          get :new, params: wrong_user_params
          expect(flash[:alert]).to eq I18n.t('identity_proofs.errors.wrong_user', proving: 'someone_else', current: user.account.username)
        end
      end

      context 'with params to prove the same username cased differently' do
        let(:capitalized_username) { new_proof_params.merge(username: user.account.username.upcase) }

        it 'renders the new template' do
          get :new, params: capitalized_username
          expect(response).to render_template(:new)
        end
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

        it 'does not post a status' do
          expect(PostStatusService).not_to receive(:new)
          post :create, params: postable_params
        end

        context 'and the user has requested to post a status' do
          let(:postable_params_with_status) do
            postable_params.tap { |p| p[:account_identity_proof][:post_status] = '1' }
          end

          it 'posts a status' do
            expect_any_instance_of(PostStatusService).to receive(:call).with(user.account, text: status_text)

            post :create, params: postable_params_with_status
          end
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
