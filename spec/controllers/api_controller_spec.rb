# frozen_string_literal: true

require 'rails_helper'

describe ApiController, type: :controller do
  controller do
    def success
      head 200
    end
  end

  before do
    routes.draw { post 'success' => 'api#success' }
  end

  it 'does not protect from forgery' do
    ActionController::Base.allow_forgery_protection = true
    post 'success'
    expect(response).to have_http_status(:success)
  end

  describe 'rate limiting' do
    context 'throttling is off' do
      before do
        request.env['rack.attack.throttle_data'] = nil
      end

      it 'does not apply rate limiting' do
        post 'success'

        expect(response.headers['X-RateLimit-Limit']).to be_nil
        expect(response.headers['X-RateLimit-Remaining']).to be_nil
        expect(response.headers['X-RateLimit-Reset']).to be_nil
      end
    end

    context 'throttling is on' do
      before do
        request.env['rack.attack.throttle_data'] = { 'api' => { limit: 100, count: 20, period: 10 } }
      end

      it 'applies rate limiting' do
        start_time = DateTime.new(2017, 1, 1, 12, 0, 0).utc
        travel_to start_time do
          post 'success'
        end

        expect(response.headers['X-RateLimit-Limit']).to eq '100'
        expect(response.headers['X-RateLimit-Remaining']).to eq '80'
        expect(response.headers['X-RateLimit-Reset']).to eq (start_time + 10.seconds).iso8601(6)
      end
    end
  end
end
