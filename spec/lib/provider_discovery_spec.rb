# frozen_string_literal: true

require 'rails_helper'

describe ProviderDiscovery do
  describe 'discover_provider' do
    context 'when status code is 200 and MIME type is text/html' do
      context 'Both of JSON and XML provider are discoverable' do
        before do
          stub_request(:get, 'https://host/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_json_xml.html')
          )
        end

        it 'returns new OEmbed::Provider for JSON provider if :format option is set to :json' do
          provider = ProviderDiscovery.discover_provider('https://host/oembed.html', format: :json)
          expect(provider.endpoint).to eq 'https://host/provider.json'
          expect(provider.format).to eq :json
        end

        it 'returns new OEmbed::Provider for XML provider if :format option is set to :xml' do
          provider = ProviderDiscovery.discover_provider('https://host/oembed.html', format: :xml)
          expect(provider.endpoint).to eq 'https://host/provider.xml'
          expect(provider.format).to eq :xml
        end
      end

      context 'JSON provider is discoverable while XML provider is not' do
        before do
          stub_request(:get, 'https://host/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_json.html')
          )
        end

        it 'returns new OEmbed::Provider for JSON provider' do
          provider = ProviderDiscovery.discover_provider('https://host/oembed.html')
          expect(provider.endpoint).to eq 'https://host/provider.json'
          expect(provider.format).to eq :json
        end
      end

      context 'XML provider is discoverable while JSON provider is not' do
        before do
          stub_request(:get, 'https://host/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_xml.html')
          )
        end

        it 'returns new OEmbed::Provider for XML provider' do
          provider = ProviderDiscovery.discover_provider('https://host/oembed.html')
          expect(provider.endpoint).to eq 'https://host/provider.xml'
          expect(provider.format).to eq :xml
        end
      end

      context 'Invalid XML provider is discoverable while JSON provider is not' do
        before do
          stub_request(:get, 'https://host/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_invalid_xml.html')
          )
        end

        it 'raises OEmbed::NotFound' do
          expect { ProviderDiscovery.discover_provider('https://host/oembed.html') }.to raise_error OEmbed::NotFound
        end
      end

      context 'Neither of JSON and XML provider is discoverable' do
        before do
          stub_request(:get, 'https://host/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_undiscoverable.html')
          )
        end

        it 'raises OEmbed::NotFound' do
          expect { ProviderDiscovery.discover_provider('https://host/oembed.html') }.to raise_error OEmbed::NotFound
        end
      end
    end

    context 'when status code is not 200' do
      before do
        stub_request(:get, 'https://host/oembed.html').to_return(
          status: 400,
          headers: { 'Content-Type': 'text/html' },
          body: request_fixture('oembed_xml.html')
        )
      end

      it 'raises OEmbed::NotFound' do
        expect { ProviderDiscovery.discover_provider('https://host/oembed.html') }.to raise_error OEmbed::NotFound
      end
    end

    context 'when MIME type is not text/html' do
      before do
        stub_request(:get, 'https://host/oembed.html').to_return(
          status: 200,
          body: request_fixture('oembed_xml.html')
        )
      end

      it 'raises OEmbed::NotFound' do
        expect { ProviderDiscovery.discover_provider('https://host/oembed.html') }.to raise_error OEmbed::NotFound
      end
    end
  end
end
