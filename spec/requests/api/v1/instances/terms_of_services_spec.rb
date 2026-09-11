# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Terms of Service' do
  describe 'GET /api/v1/instance/terms_of_service' do
    context 'with a current TOS record' do
      before do
        Fabricate(:terms_of_service)
      end

      it 'returns http success' do
        get api_v1_instance_terms_of_service_index_path

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq('application/json')

        expect(response.parsed_body)
          .to be_present
          .and include(:content)
      end
    end

    context 'without a current TOS record' do
      it 'returns http success' do
        get api_v1_instance_terms_of_service_index_path

        expect(response)
          .to have_http_status(404)
        expect(response.media_type)
          .to eq('application/json')

        expect(response.parsed_body)
          .to be_present
          .and include(error: /not found/i)
      end
    end
  end

  describe 'GET /api/v1/instance/terms_of_service/:date' do
    context 'with an effective TOS record' do
      before do
        travel_to 2.days.ago do
          Fabricate(:terms_of_service, effective_date: 2.days.from_now, published_at: Date.current)
        end
      end

      it 'returns http success' do
        get api_v1_instance_terms_of_service_path(date: Date.current.to_s)

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq('application/json')

        expect(response.parsed_body)
          .to be_present
          .and include(:content)
      end
    end

    context 'without an effective TOS record' do
      it 'returns http not found' do
        get api_v1_instance_terms_of_service_path(date: Date.current.to_s)

        expect(response)
          .to have_http_status(404)
        expect(response.media_type)
          .to eq('application/json')

        expect(response.parsed_body)
          .to be_present
          .and include(error: /not found/i)
      end
    end
  end
end
