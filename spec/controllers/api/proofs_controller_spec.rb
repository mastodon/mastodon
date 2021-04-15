require 'rails_helper'

describe Api::ProofsController do
  let(:alice) { Fabricate(:account, username: 'alice') }

  before do
    stub_request(:get, 'https://keybase.io/_/api/1.0/sig/proof_valid.json?domain=cb6e6126.ngrok.io&kb_username=crypto_alice&sig_hash=111111111111111111111111111111111111111111111111111111111111111111&username=alice').to_return(status: 200, body: '{"proof_valid":true,"proof_live":false}')
    stub_request(:get, 'https://keybase.io/_/api/1.0/sig/proof_live.json?domain=cb6e6126.ngrok.io&kb_username=crypto_alice&sig_hash=111111111111111111111111111111111111111111111111111111111111111111&username=alice').to_return(status: 200, body: '{"proof_valid":true,"proof_live":true}')
    stub_request(:get, 'https://keybase.io/_/api/1.0/sig/proof_valid.json?domain=cb6e6126.ngrok.io&kb_username=hidden_alice&sig_hash=222222222222222222222222222222222222222222222222222222222222222222&username=alice').to_return(status: 200, body: '{"proof_valid":true,"proof_live":true}')
    stub_request(:get, 'https://keybase.io/_/api/1.0/sig/proof_live.json?domain=cb6e6126.ngrok.io&kb_username=hidden_alice&sig_hash=222222222222222222222222222222222222222222222222222222222222222222&username=alice').to_return(status: 200, body: '{"proof_valid":true,"proof_live":true}')
  end

  describe 'GET #index' do
    describe 'with a non-existent username' do
      it '404s' do
        get :index, params: { username: 'nonexistent', provider: 'keybase' }

        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'with a user that has no proofs' do
      it 'is an empty list of signatures' do
        get :index, params: { username: alice.username, provider: 'keybase' }

        expect(body_as_json[:signatures]).to eq []
      end
    end

    describe 'with a user that has a live, valid proof' do
      let(:token1) { '111111111111111111111111111111111111111111111111111111111111111111' }
      let(:kb_name1) { 'crypto_alice' }

      before do
        Fabricate(:account_identity_proof, account: alice, verified: true, live: true, token: token1, provider_username: kb_name1)
      end

      it 'is a list with that proof in it' do
        get :index, params: { username: alice.username, provider: 'keybase' }

        expect(body_as_json[:signatures]).to eq [
          { kb_username: kb_name1, sig_hash: token1 },
        ]
      end

      describe 'add one that is neither live nor valid' do
        let(:token2) { '222222222222222222222222222222222222222222222222222222222222222222' }
        let(:kb_name2) { 'hidden_alice' }

        before do
          Fabricate(:account_identity_proof, account: alice, verified: false, live: false, token: token2, provider_username: kb_name2)
        end

        it 'is a list with both proofs' do
          get :index, params: { username: alice.username, provider: 'keybase' }

          expect(body_as_json[:signatures]).to eq [
            { kb_username: kb_name1, sig_hash: token1 },
            { kb_username: kb_name2, sig_hash: token2 },
          ]
        end
      end
    end

    describe 'a user that has an avatar' do
      let(:alice) { Fabricate(:account, username: 'alice', avatar: attachment_fixture('avatar.gif')) }

      context 'and a proof' do
        let(:token1) { '111111111111111111111111111111111111111111111111111111111111111111' }
        let(:kb_name1) { 'crypto_alice' }

        before do
          Fabricate(:account_identity_proof, account: alice, verified: true, live: true, token: token1, provider_username: kb_name1)
          get :index, params: { username: alice.username, provider: 'keybase' }
        end

        it 'has two keys: signatures and avatar' do
          expect(body_as_json.keys).to match_array [:signatures, :avatar]
        end

        it 'has the correct signatures' do
          expect(body_as_json[:signatures]).to eq [
            { kb_username: kb_name1, sig_hash: token1 },
          ]
        end

        it 'has the correct avatar url' do
          expect(body_as_json[:avatar]).to match "https://cb6e6126.ngrok.io#{alice.avatar.url}"
        end
      end
    end
  end
end
