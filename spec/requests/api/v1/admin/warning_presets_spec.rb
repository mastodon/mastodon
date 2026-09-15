# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Warning presets' do
  include_context 'with API authentication', user_fabricator: :admin_user, oauth_scopes: 'admin:read:reports'

  describe 'GET /api/v1/admin/warning_presets' do
    subject do
      get '/api/v1/admin/warning_presets', headers: headers, params: params
    end

    let(:params) { {} }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    context 'when there are no presets' do
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

    context 'when there are presets' do
      let!(:preset) { Fabricate(:account_warning_preset, title: 'Simple moderation warning', text: 'Boilerplate here') }

      it 'returns all available presets' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to match_array(a_hash_including({
            'id' => preset.id.to_s,
            'text' => preset.text,
            'title' => preset.title,
          }))
      end
    end
  end

  describe 'GET /api/v1/admin/reports/:id' do
    subject do
      get "/api/v1/admin/reports/#{report.id}", headers: headers
    end

    let(:report) { Fabricate(:report) }

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns the requested report content', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to include(
        {
          id: report.id.to_s,
          action_taken: report.action_taken?,
          category: report.category,
          comment: report.comment,
          account: a_hash_including(id: report.account.id.to_s),
          target_account: a_hash_including(id: report.target_account.id.to_s),
          statuses: report.statuses,
          rules: report.rules,
          forwarded: report.forwarded,
        }
      )
    end
  end
end
