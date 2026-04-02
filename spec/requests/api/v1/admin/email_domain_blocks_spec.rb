# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Email Domain Blocks' do
  include_context 'with API authentication', user_fabricator: :admin_user, oauth_scopes: 'admin:read:email_domain_blocks admin:write:email_domain_blocks'

  describe 'GET /api/v1/admin/email_domain_blocks' do
    subject do
      get '/api/v1/admin/email_domain_blocks', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    context 'when there is no email domain block' do
      it 'returns an empty list' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to be_empty
      end
    end

    context 'when there are email domain blocks' do
      let!(:email_domain_blocks)  { Fabricate.times(5, :email_domain_block) }
      let(:blocked_email_domains) { email_domain_blocks.pluck(:domain) }

      it 'return the correct blocked email domains' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body.pluck(:domain))
          .to match_array(blocked_email_domains)
      end

      context 'with limit param' do
        let(:params) { { limit: 2 } }

        it 'returns only the requested number of email domain blocks' do
          subject

          expect(response.parsed_body.size).to eq(params[:limit])
        end
      end

      context 'with since_id param' do
        let(:params) { { since_id: email_domain_blocks[1].id } }

        it 'returns only the email domain blocks after since_id' do
          subject

          email_domain_blocks_ids = email_domain_blocks.pluck(:id).map(&:to_s)

          expect(response.parsed_body.pluck(:id)).to match_array(email_domain_blocks_ids[2..])
        end
      end

      context 'with max_id param' do
        let(:params) { { max_id: email_domain_blocks[3].id } }

        it 'returns only the email domain blocks before max_id' do
          subject

          email_domain_blocks_ids = email_domain_blocks.pluck(:id).map(&:to_s)

          expect(response.parsed_body.pluck(:id)).to match_array(email_domain_blocks_ids[..2])
        end
      end
    end
  end

  describe 'GET /api/v1/admin/email_domain_blocks/:id' do
    subject do
      get "/api/v1/admin/email_domain_blocks/#{email_domain_block.id}", headers: headers
    end

    let!(:email_domain_block) { Fabricate(:email_domain_block) }

    it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    context 'when email domain block exists' do
      it 'returns the correct blocked domain', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:domain]).to eq(email_domain_block.domain)
      end
    end

    context 'when email domain block does not exist' do
      it 'returns http not found' do
        get '/api/v1/admin/email_domain_blocks/-1', headers: headers

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/admin/email_domain_blocks' do
    subject do
      post '/api/v1/admin/email_domain_blocks', headers: headers, params: params
    end

    let(:params) { { domain: 'example.com' } }

    it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns the correct blocked email domain', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body[:domain]).to eq(params[:domain])
    end

    context 'when domain param is not provided' do
      let(:params) { { domain: '' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when provided domain name has an invalid character' do
      let(:params) { { domain: 'do\uD800.com' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when provided domain is already blocked' do
      before do
        EmailDomainBlock.create(params)
      end

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'DELETE /api/v1/admin/email_domain_blocks' do
    subject do
      delete "/api/v1/admin/email_domain_blocks/#{email_domain_block.id}", headers: headers
    end

    let!(:email_domain_block) { Fabricate(:email_domain_block) }

    it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'deletes email domain block', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to be_empty
      expect(EmailDomainBlock.find_by(id: email_domain_block.id)).to be_nil
    end

    context 'when email domain block does not exist' do
      it 'returns http not found' do
        delete '/api/v1/admin/email_domain_blocks/-1', headers: headers

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
