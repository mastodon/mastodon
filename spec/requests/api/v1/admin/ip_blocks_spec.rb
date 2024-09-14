# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'IP Blocks' do
  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'admin:read:ip_blocks admin:write:ip_blocks' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/admin/ip_blocks' do
    subject do
      get '/api/v1/admin/ip_blocks', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'admin:write:ip_blocks'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    context 'when there is no ip block' do
      it 'returns an empty body' do
        subject

        expect(response.parsed_body).to be_empty
      end
    end

    context 'when there are ip blocks' do
      let!(:ip_blocks) do
        [
          IpBlock.create(ip: '192.0.2.0/24', severity: :no_access),
          IpBlock.create(ip: '172.16.0.1', severity: :sign_up_requires_approval, comment: 'Spam'),
          IpBlock.create(ip: '2001:0db8::/32', severity: :sign_up_block, expires_in: 10.days),
        ]
      end
      let(:expected_response) do
        ip_blocks.map do |ip_block|
          {
            id: ip_block.id.to_s,
            ip: ip_block.ip,
            severity: ip_block.severity.to_s,
            comment: ip_block.comment,
            created_at: ip_block.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
            expires_at: ip_block.expires_at&.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
          }
        end
      end

      it 'returns the correct blocked ips' do
        subject

        expect(response.parsed_body).to match_array(expected_response)
      end

      context 'with limit param' do
        let(:params) { { limit: 2 } }

        it 'returns only the requested number of ip blocks' do
          subject

          expect(response.parsed_body.size).to eq(params[:limit])
        end
      end
    end
  end

  describe 'GET /api/v1/admin/ip_blocks/:id' do
    subject do
      get "/api/v1/admin/ip_blocks/#{ip_block.id}", headers: headers
    end

    let!(:ip_block) { IpBlock.create(ip: '192.0.2.0/24', severity: :no_access) }

    it_behaves_like 'forbidden for wrong scope', 'admin:write:ip_blocks'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns the correct ip block', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)

      expect(response.parsed_body)
        .to include(
          ip: eq("#{ip_block.ip}/#{ip_block.ip.prefix}"),
          severity: eq(ip_block.severity.to_s)
        )
    end

    context 'when ip block does not exist' do
      it 'returns http not found' do
        get '/api/v1/admin/ip_blocks/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/admin/ip_blocks' do
    subject do
      post '/api/v1/admin/ip_blocks', headers: headers, params: params
    end

    let(:params) { { ip: '151.0.32.55', severity: 'no_access', comment: 'Spam' } }

    it_behaves_like 'forbidden for wrong scope', 'admin:read:ip_blocks'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns the correct ip block', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body)
        .to include(
          ip: eq("#{params[:ip]}/32"),
          severity: eq(params[:severity]),
          comment: eq(params[:comment])
        )
    end

    context 'when the required ip param is not provided' do
      let(:params) { { ip: '', severity: 'no_access' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'when the required severity param is not provided' do
      let(:params) { { ip: '173.65.23.1', severity: '' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'when the given ip address is already blocked' do
      before do
        IpBlock.create(params)
      end

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'when the given ip address is invalid' do
      let(:params) { { ip: '520.13.54.120', severity: 'no_access' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT /api/v1/admin/ip_blocks/:id' do
    subject do
      put "/api/v1/admin/ip_blocks/#{ip_block.id}", headers: headers, params: params
    end

    let!(:ip_block) { IpBlock.create(ip: '185.200.13.3', severity: 'no_access', comment: 'Spam', expires_in: 48.hours) }
    let(:params)    { { severity: 'sign_up_requires_approval', comment: 'Decreasing severity' } }

    it 'returns the correct ip block', :aggregate_failures do
      expect { subject }
        .to change_severity_level
        .and change_comment_value

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match(hash_including({
        ip: "#{ip_block.ip}/#{ip_block.ip.prefix}",
        severity: 'sign_up_requires_approval',
        comment: 'Decreasing severity',
      }))
    end

    def change_severity_level
      change { ip_block.reload.severity }.from('no_access').to('sign_up_requires_approval')
    end

    def change_comment_value
      change { ip_block.reload.comment }.from('Spam').to('Decreasing severity')
    end

    context 'when ip block does not exist' do
      it 'returns http not found' do
        put '/api/v1/admin/ip_blocks/-1', headers: headers, params: params

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /api/v1/admin/ip_blocks/:id' do
    subject do
      delete "/api/v1/admin/ip_blocks/#{ip_block.id}", headers: headers
    end

    let!(:ip_block) { IpBlock.create(ip: '185.200.13.3', severity: 'no_access') }

    it 'deletes the ip block', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to be_empty
      expect(IpBlock.find_by(id: ip_block.id)).to be_nil
    end

    context 'when ip block does not exist' do
      it 'returns http not found' do
        delete '/api/v1/admin/ip_blocks/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end
end
