# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'robots.txt' do
  describe 'GET /robots.txt' do
    subject { get '/robots.txt' }

    context 'when set to override' do
      before do
        Setting.override_robots = true
        Setting.custom_robots = 'hoge'
      end

      it 'returns custom robots.txt' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq('text/plain')
        expect(response.body)
          .to eq('hoge')
      end
    end

    context 'when using default but a custom robots.txt exists' do
      before do
        Setting.override_robots = false
        Setting.custom_robots = 'hoge'
      end

      it 'returns default robots.txt' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq('text/plain')
        expect(response.body)
          .to eq(RobotsController::DEFAULT_ROBOTS)
      end
    end

    context 'when using default robots.txt' do
      it 'returns default robots.txt' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq('text/plain')
        expect(response.body)
          .to eq(RobotsController::DEFAULT_ROBOTS)
      end
    end
  end
end
