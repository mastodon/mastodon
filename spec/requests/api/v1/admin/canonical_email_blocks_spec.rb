# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Canonical Email Blocks' do
  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'admin:read:canonical_email_blocks admin:write:canonical_email_blocks' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/admin/canonical_email_blocks' do
    subject do
      get '/api/v1/admin/canonical_email_blocks', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    context 'when there is no canonical email block' do
      it 'returns an empty list' do
        subject

        expect(body_as_json).to be_empty
      end
    end

    context 'when there are canonical email blocks' do
      let!(:canonical_email_blocks) { Fabricate.times(5, :canonical_email_block) }
      let(:expected_email_hashes)   { canonical_email_blocks.pluck(:canonical_email_hash) }

      it 'returns the correct canonical email hashes' do
        subject

        expect(body_as_json.pluck(:canonical_email_hash)).to match_array(expected_email_hashes)
      end

      context 'with limit param' do
        let(:params) { { limit: 2 } }

        it 'returns only the requested number of canonical email blocks' do
          subject

          expect(body_as_json.size).to eq(params[:limit])
        end
      end

      context 'with since_id param' do
        let(:params) { { since_id: canonical_email_blocks[1].id } }

        it 'returns only the canonical email blocks after since_id' do
          subject

          canonical_email_blocks_ids = canonical_email_blocks.pluck(:id).map(&:to_s)

          expect(body_as_json.pluck(:id)).to match_array(canonical_email_blocks_ids[2..])
        end
      end

      context 'with max_id param' do
        let(:params) { { max_id: canonical_email_blocks[3].id } }

        it 'returns only the canonical email blocks before max_id' do
          subject

          canonical_email_blocks_ids = canonical_email_blocks.pluck(:id).map(&:to_s)

          expect(body_as_json.pluck(:id)).to match_array(canonical_email_blocks_ids[..2])
        end
      end
    end
  end

  describe 'GET /api/v1/admin/canonical_email_blocks/:id' do
    subject do
      get "/api/v1/admin/canonical_email_blocks/#{canonical_email_block.id}", headers: headers
    end

    let!(:canonical_email_block) { Fabricate(:canonical_email_block) }

    it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    context 'when the requested canonical email block exists' do
      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'returns the requested canonical email block data correctly' do
        subject

        json = body_as_json

        expect(json[:id]).to eq(canonical_email_block.id.to_s)
        expect(json[:canonical_email_hash]).to eq(canonical_email_block.canonical_email_hash)
      end
    end

    context 'when the requested canonical block does not exist' do
      it 'returns http not found' do
        get '/api/v1/admin/canonical_email_blocks/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/admin/canonical_email_blocks/test' do
    subject do
      post '/api/v1/admin/canonical_email_blocks/test', headers: headers, params: params
    end

    let(:params) { { email: 'email@example.com' } }

    it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    context 'when the required email param is not provided' do
      let(:params) { {} }

      it 'returns http bad request' do
        subject

        expect(response).to have_http_status(400)
      end
    end

    context 'when the required email param is provided' do
      context 'when there is a matching canonical email block' do
        let!(:canonical_email_block) { CanonicalEmailBlock.create(params) }

        it 'returns http success' do
          subject

          expect(response).to have_http_status(200)
        end

        it 'returns the expected canonical email hash' do
          subject

          expect(body_as_json[0][:canonical_email_hash]).to eq(canonical_email_block.canonical_email_hash)
        end
      end

      context 'when there is no matching canonical email block' do
        it 'returns http success' do
          subject

          expect(response).to have_http_status(200)
        end

        it 'returns an empty list' do
          subject

          expect(body_as_json).to be_empty
        end
      end
    end
  end

  describe 'POST /api/v1/admin/canonical_email_blocks' do
    subject do
      post '/api/v1/admin/canonical_email_blocks', headers: headers, params: params
    end

    let(:params)                { { email: 'example@email.com' } }
    let(:canonical_email_block) { CanonicalEmailBlock.new(email: params[:email]) }

    it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns the canonical_email_hash correctly' do
      subject

      expect(body_as_json[:canonical_email_hash]).to eq(canonical_email_block.canonical_email_hash)
    end

    context 'when the required email param is not provided' do
      let(:params) { {} }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'when the canonical_email_hash param is provided instead of email' do
      let(:params) { { canonical_email_hash: 'dd501ce4e6b08698f19df96f2f15737e48a75660b1fa79b6ff58ea25ee4851a4' } }

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'returns the correct canonical_email_hash' do
        subject

        expect(body_as_json[:canonical_email_hash]).to eq(params[:canonical_email_hash])
      end
    end

    context 'when both email and canonical_email_hash params are provided' do
      let(:params) { { email: 'example@email.com', canonical_email_hash: 'dd501ce4e6b08698f19df96f2f15737e48a75660b1fa79b6ff58ea25ee4851a4' } }

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'ignores the canonical_email_hash param' do
        subject

        expect(body_as_json[:canonical_email_hash]).to eq(canonical_email_block.canonical_email_hash)
      end
    end

    context 'when the given canonical email was already blocked' do
      before do
        canonical_email_block.save
      end

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /api/v1/admin/canonical_email_blocks/:id' do
    subject do
      delete "/api/v1/admin/canonical_email_blocks/#{canonical_email_block.id}", headers: headers
    end

    let!(:canonical_email_block) { Fabricate(:canonical_email_block) }

    it_behaves_like 'forbidden for wrong scope', 'read:statuses'

    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'deletes the canonical email block' do
      subject

      expect(CanonicalEmailBlock.find_by(id: canonical_email_block.id)).to be_nil
    end

    context 'when the canonical email block is not found' do
      it 'returns http not found' do
        delete '/api/v1/admin/canonical_email_blocks/0', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end
end
