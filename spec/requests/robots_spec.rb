# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'robots.txt' do
  describe 'GET /robots.txt' do
    subject { get '/robots.txt' }

    context 'when set to override' do
      before do
        Setting.override_robots = true
        Setting.custom_robots = 'hoge'
        subject
      end

      it 'returns http success' do
        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('text/plain')
      end

      it 'returns custom robots.txt' do
        expect(response.body)
          .to eq('hoge')
      end
    end

    context 'when using default but a custom robots.txt exists' do
      before do
        Setting.override_robots = false
        Setting.custom_robots = 'hoge'
        subject
      end

      it 'returns http success' do
        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('text/plain')
      end

      it 'returns custom robots.txt' do
        expect(response.body)
          .to eq(RobotsController::DEFAULT_ROBOTS)
      end
    end

    context 'when using default robots.txt' do
      before do
        subject
      end

      it 'returns http success' do
        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('text/plain')
      end

      it 'returns custom robots.txt' do
        expect(response.body)
          .to eq(RobotsController::DEFAULT_ROBOTS)
      end
    end
  end
end
