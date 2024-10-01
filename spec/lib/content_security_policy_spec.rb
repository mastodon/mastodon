# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentSecurityPolicy do
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

  describe '#media_hosts' do
    context 'when there is no configured CDN' do
      it 'defaults to using the assets_host value' do
        expect(subject.media_hosts).to contain_exactly(subject.assets_host)
      end
    end

    context 'when an S3 alias host is configured' do
      around do |example|
        ClimateControl.modify S3_ALIAS_HOST: 'asset-host.s3-alias.example' do
          example.run
        end
      end

      it 'uses the s3 alias host value' do
        expect(subject.media_hosts).to contain_exactly(subject.assets_host, 'https://asset-host.s3-alias.example')
      end
    end

    context 'when an S3 alias host with a trailing path is configured' do
      around do |example|
        ClimateControl.modify S3_ALIAS_HOST: 'asset-host.s3-alias.example/pathname' do
          example.run
        end
      end

      it 'uses the s3 alias host value and preserves the path' do
        expect(subject.media_hosts).to contain_exactly(subject.assets_host, 'https://asset-host.s3-alias.example/pathname/')
      end
    end

    context 'when an S3 cloudfront host is configured' do
      around do |example|
        ClimateControl.modify S3_CLOUDFRONT_HOST: 'asset-host.s3-cloudfront.example' do
          example.run
        end
      end

      it 'uses the s3 cloudfront host value' do
        expect(subject.media_hosts).to contain_exactly(subject.assets_host, 'https://asset-host.s3-cloudfront.example')
      end
    end

    context 'when an azure alias host is configured' do
      around do |example|
        ClimateControl.modify AZURE_ALIAS_HOST: 'asset-host.azure-alias.example' do
          example.run
        end
      end

      it 'uses the azure alias host value' do
        expect(subject.media_hosts).to contain_exactly(subject.assets_host, 'https://asset-host.azure-alias.example')
      end
    end

    context 'when s3_enabled is configured' do
      around do |example|
        ClimateControl.modify S3_ENABLED: 'true', S3_HOSTNAME: 'asset-host.s3.example' do
          example.run
        end
      end

      it 'uses the s3 hostname host value' do
        expect(subject.media_hosts).to contain_exactly(subject.assets_host, 'https://asset-host.s3.example')
      end
    end

    context 'when PAPERCLIP_ROOT_URL is configured' do
      around do |example|
        ClimateControl.modify PAPERCLIP_ROOT_URL: 'https://paperclip-host.example' do
          example.run
        end
      end

      it 'uses the provided URL in the content security policy' do
        expect(subject.media_hosts).to contain_exactly(subject.assets_host, 'https://paperclip-host.example')
      end
    end
  end
end
