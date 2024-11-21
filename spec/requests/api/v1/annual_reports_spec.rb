# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Annual Reports' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/annual_reports' do
    context 'when not authorized' do
      it 'returns http unauthorized' do
        get api_v1_annual_reports_path

        expect(response)
          .to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with wrong scope' do
      before do
        get api_v1_annual_reports_path, headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'write write:accounts'
    end

    context 'with correct scope' do
      let(:scopes) { 'read:accounts' }

      it 'returns http success' do
        get api_v1_annual_reports_path, headers: headers

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
      end
    end
  end

  describe 'POST /api/v1/annual_reports/:id/read' do
    context 'with correct scope' do
      let(:scopes) { 'write:accounts' }

      it 'returns success and marks the report as read' do
        annual_report = Fabricate :generated_annual_report, account: user.account

        expect { post read_api_v1_annual_report_path(id: annual_report.year), headers: headers }
          .to change { annual_report.reload.viewed? }.to(true)
        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
