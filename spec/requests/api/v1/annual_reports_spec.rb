# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Annual Reports' do
  include_context 'with API authentication'

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

  describe 'GET /api/v1/annual_reports/:year/state' do
    context 'when not authorized' do
      it 'returns http unauthorized' do
        get '/api/v1/annual_reports/2025/state'

        expect(response)
          .to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with wrong scope' do
      before do
        get '/api/v1/annual_reports/2025/state', headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'write write:accounts'
    end

    context 'with correct scope' do
      let(:scopes) { 'read:accounts' }

      context 'when a report is already generated' do
        before do
          Fabricate(:generated_annual_report, account: user.account, year: 2025)
        end

        it 'returns http success and available status' do
          get '/api/v1/annual_reports/2025/state', headers: headers

          expect(response)
            .to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to be_present
            .and include(state: 'available')
        end
      end

      context 'when the feature is not enabled' do
        before do
          Setting.wrapstodon = false
        end

        it 'returns http success and ineligible status' do
          get '/api/v1/annual_reports/2025/state', headers: headers

          expect(response)
            .to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to be_present
            .and include(state: 'ineligible')
        end
      end

      context 'when the feature is enabled and time is within window' do
        before do
          travel_to Time.utc(2025, 12, 20)

          # Define the ID manually as it is otherwise handled by the database, which is not affected by `travel_to`
          status = Fabricate(:status, visibility: :public, account: user.account, id: Mastodon::Snowflake.id_at(Time.now.utc))
          status.tags << Fabricate(:tag)
        end

        it 'returns http success and eligible status' do
          get '/api/v1/annual_reports/2025/state', headers: headers

          expect(response)
            .to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to be_present
            .and include(state: 'eligible')
        end
      end

      context 'when the feature is enabled but we are out of the time window' do
        before do
          travel_to Time.utc(2025, 6, 20)

          # Define the ID manually as it is otherwise handled by the database, which is not affected by `travel_to`
          status = Fabricate(:status, visibility: :public, account: user.account, id: Mastodon::Snowflake.id_at(Time.now.utc))
          status.tags << Fabricate(:tag)
        end

        it 'returns http success and ineligible status' do
          get '/api/v1/annual_reports/2025/state', headers: headers

          expect(response)
            .to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to be_present
            .and include(state: 'ineligible')
        end
      end
    end
  end

  describe 'POST /api/v1/annual_reports/:id/generate' do
    context 'when not authorized' do
      it 'returns http unauthorized' do
        post '/api/v1/annual_reports/2025/generate'

        expect(response)
          .to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with wrong scope' do
      before do
        post '/api/v1/annual_reports/2025/generate', headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'read read:accounts'
    end

    context 'with correct scope' do
      let(:scopes) { 'write:accounts' }

      context 'when the feature is enabled and time is within window' do
        before do
          travel_to Time.utc(2025, 12, 20)

          status = Fabricate(:status, visibility: :public, account: user.account)
          status.tags << Fabricate(:tag)
        end

        it 'returns http accepted, create an async job and schedules a job' do
          expect { post '/api/v1/annual_reports/2025/generate', headers: headers }
            .to enqueue_sidekiq_job(GenerateAnnualReportWorker).with(user.account_id, 2025)

          expect(response)
            .to have_http_status(202)

          expect(response.headers['Mastodon-Async-Refresh']).to be_present
        end
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
