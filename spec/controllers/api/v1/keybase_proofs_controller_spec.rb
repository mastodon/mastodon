require 'rails_helper'

describe Api::V1::KeybaseProofsController do

  let(:alice) { Fabricate(:account, username: 'alice') }

  describe 'GET #index' do
    describe 'with a non-existent username' do
      it '404s' do
        get :index, params: { username: 'nonexistent' }

        expect(response.status).to eq 404
      end
    end

    describe 'with a user that has no proofs' do
      it 'is an empty list of signatures' do
        get :index, params: { username: alice.username }

        expect(body_as_json).to eq signatures: []
      end
    end

    describe 'with a user that has a live, valid proof' do
      let(:token1) { '111111111111111111111111111111111111111111111111111111111111111111' }
      let(:kb_name1) { 'crypto_alice' }

      before do
        Fabricate(:account_identity_proof, account: alice, is_valid: true, is_live: true,
          token: token1, provider_username: kb_name1)
      end

      it 'is a list with that proof in it' do
        get :index, params: { username: alice.username }

        expect(body_as_json).to eq signatures: [ {kb_username: kb_name1, sig_hash: token1} ]
      end

      describe 'add one that is neither live nor valid' do
        let(:token2) { '222222222222222222222222222222222222222222222222222222222222222222' }
        let(:kb_name2) { 'hidden_alice' }

        before do
          Fabricate(:account_identity_proof, account: alice, is_valid: false, is_live: false,
            token: token2, provider_username: kb_name2)
        end

        it 'is a list with both proofs' do
          get :index, params: { username: alice.username }

          expect(body_as_json).to eq signatures: [
            {kb_username: kb_name1, sig_hash: token1},
            {kb_username: kb_name2, sig_hash: token2}
          ]
        end
      end
    end
  end
end
