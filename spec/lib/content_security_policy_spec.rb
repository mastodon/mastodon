# frozen_string_literal: true

require 'rails_helper'

describe ContentSecurityPolicy do
  subject { described_class.new }

  around do |example|
    original_asset_host = Rails.configuration.action_controller.asset_host
    original_web_domain = Rails.configuration.x.web_domain
    original_use_https = Rails.configuration.x.use_https
    example.run
    Rails.configuration.action_controller.asset_host = original_asset_host
    Rails.configuration.x.web_domain = original_web_domain
    Rails.configuration.x.use_https = original_use_https
  end

  describe '#base_host' do
    before { Rails.configuration.x.web_domain = 'host.example' }

    it 'returns the configured value for the web domain' do
      expect(subject.base_host).to eq 'host.example'
    end
  end

  describe '#assets_host' do
    context 'when asset_host is not configured' do
      before { Rails.configuration.action_controller.asset_host = nil }

      context 'with a configured web domain' do
        before { Rails.configuration.x.web_domain = 'host.example' }

        context 'when use_https is enabled' do
          before { Rails.configuration.x.use_https = true }

          it 'returns value from base host with https protocol' do
            expect(subject.assets_host).to eq 'https://host.example'
          end
        end

        context 'when use_https is disabled' do
          before { Rails.configuration.x.use_https = false }

          it 'returns value from base host with http protocol' do
            expect(subject.assets_host).to eq 'http://host.example'
          end
        end
      end
    end

    context 'when asset_host is configured' do
      before do
        Rails.configuration.action_controller.asset_host = 'https://assets.host.example'
      end

      it 'returns full value from configured host' do
        expect(subject.assets_host).to eq 'https://assets.host.example'
      end
    end
  end
end
