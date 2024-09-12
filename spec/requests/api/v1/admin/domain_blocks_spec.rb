# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Domain Blocks' do
  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:scopes)  { 'admin:read:domain_blocks admin:write:domain_blocks' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/admin/domain_blocks' do
    subject do
      get '/api/v1/admin/domain_blocks', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    context 'when there are no domain blocks' do
      it 'returns an empty list' do
        subject

        expect(response.parsed_body).to be_empty
      end
    end

    context 'when there are domain blocks' do
      let!(:domain_blocks) do
        [
          Fabricate(:domain_block, severity: :silence, reject_media: true),
          Fabricate(:domain_block, severity: :suspend, obfuscate: true),
          Fabricate(:domain_block, severity: :noop, reject_reports: true),
          Fabricate(:domain_block, public_comment: 'Spam'),
          Fabricate(:domain_block, private_comment: 'Spam'),
        ]
      end
      let(:expected_responde) do
        domain_blocks.map do |domain_block|
          {
            id: domain_block.id.to_s,
            domain: domain_block.domain,
            digest: domain_block.domain_digest,
            created_at: domain_block.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
            severity: domain_block.severity.to_s,
            reject_media: domain_block.reject_media,
            reject_reports: domain_block.reject_reports,
            private_comment: domain_block.private_comment,
            public_comment: domain_block.public_comment,
            obfuscate: domain_block.obfuscate,
          }
        end
      end

      it 'returns the expected domain blocks' do
        subject

        expect(response.parsed_body).to match_array(expected_responde)
      end

      context 'with limit param' do
        let(:params) { { limit: 2 } }

        it 'returns only the requested number of domain blocks' do
          subject

          expect(response.parsed_body.size).to eq(params[:limit])
        end
      end
    end
  end

  describe 'GET /api/v1/admin/domain_blocks/:id' do
    subject do
      get "/api/v1/admin/domain_blocks/#{domain_block.id}", headers: headers
    end

    let!(:domain_block) { Fabricate(:domain_block) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns the expected domain block content', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match(
        id: domain_block.id.to_s,
        domain: domain_block.domain,
        digest: domain_block.domain_digest,
        created_at: domain_block.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
        severity: domain_block.severity.to_s,
        reject_media: domain_block.reject_media,
        reject_reports: domain_block.reject_reports,
        private_comment: domain_block.private_comment,
        public_comment: domain_block.public_comment,
        obfuscate: domain_block.obfuscate
      )
    end

    context 'when the requested domain block does not exist' do
      it 'returns http not found' do
        get '/api/v1/admin/domain_blocks/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/admin/domain_blocks' do
    subject do
      post '/api/v1/admin/domain_blocks', headers: headers, params: params
    end

    let(:params) { { domain: 'foo.bar.com', severity: :silence } }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'creates a domain block with the expected domain name and severity', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match a_hash_including(
        {
          domain: 'foo.bar.com',
          severity: 'silence',
        }
      )

      expect(DomainBlock.find_by(domain: 'foo.bar.com')).to be_present
    end

    context 'when a looser domain block already exists on a higher level domain' do
      let(:params) { { domain: 'foo.bar.com', severity: :suspend } }

      before do
        Fabricate(:domain_block, domain: 'bar.com', severity: :silence)
      end

      it 'creates a domain block with the expected domain name and severity', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body).to match a_hash_including(
          {
            domain: 'foo.bar.com',
            severity: 'suspend',
          }
        )

        expect(DomainBlock.find_by(domain: 'foo.bar.com')).to be_present
      end
    end

    context 'when a domain block already exists on the same domain' do
      before do
        Fabricate(:domain_block, domain: 'foo.bar.com', severity: :silence)
      end

      it 'returns existing domain block in error', :aggregate_failures do
        subject

        expect(response).to have_http_status(422)
        expect(response.parsed_body[:existing_domain_block][:domain]).to eq('foo.bar.com')
      end
    end

    context 'when a stricter domain block already exists on a higher level domain' do
      before do
        Fabricate(:domain_block, domain: 'bar.com', severity: :suspend)
      end

      it 'returns existing domain block in error', :aggregate_failures do
        subject

        expect(response).to have_http_status(422)
        expect(response.parsed_body[:existing_domain_block][:domain]).to eq('bar.com')
      end
    end

    context 'when given domain name is invalid' do
      let(:params) { { domain: 'foo bar', severity: :silence } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT /api/v1/admin/domain_blocks/:id' do
    subject do
      put "/api/v1/admin/domain_blocks/#{domain_block.id}", headers: headers, params: params
    end

    let!(:domain_block)   { Fabricate(:domain_block, domain: 'example.com', severity: :silence) }
    let(:params)          { { domain: 'example.com', severity: 'suspend' } }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns the updated domain block', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match a_hash_including(
        {
          id: domain_block.id.to_s,
          domain: domain_block.domain,
          digest: domain_block.domain_digest,
          severity: 'suspend',
        }
      )
    end

    it 'updates the block severity' do
      expect { subject }.to change { domain_block.reload.severity }.from('silence').to('suspend')
    end

    context 'when domain block does not exist' do
      it 'returns http not found' do
        put '/api/v1/admin/domain_blocks/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /api/v1/admin/domain_blocks/:id' do
    subject do
      delete "/api/v1/admin/domain_blocks/#{domain_block.id}", headers: headers
    end

    let!(:domain_block) { Fabricate(:domain_block) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'deletes the domain block', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(DomainBlock.find_by(id: domain_block.id)).to be_nil
    end

    context 'when domain block does not exist' do
      it 'returns http not found' do
        delete '/api/v1/admin/domain_blocks/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end
end
