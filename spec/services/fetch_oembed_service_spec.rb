# frozen_string_literal: true

require 'rails_helper'

describe FetchOEmbedService, type: :service do
  subject { described_class.new }

  before do
    stub_request(:get, "https://host.test/provider.json").to_return(status: 404)
    stub_request(:get, "https://host.test/provider.xml").to_return(status: 404)
    stub_request(:get, "https://host.test/empty_provider.json").to_return(status: 200)
  end

  describe 'discover_provider' do
    context 'when status code is 200 and MIME type is text/html' do
      context 'Both of JSON and XML provider are discoverable' do
        before do
          stub_request(:get, 'https://host.test/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_json_xml.html')
          )
        end

        it 'returns new OEmbed::Provider for JSON provider if :format option is set to :json' do
          subject.call('https://host.test/oembed.html', format: :json)
          expect(subject.endpoint_url).to eq 'https://host.test/provider.json'
          expect(subject.format).to eq :json
        end

        it 'returns new OEmbed::Provider for XML provider if :format option is set to :xml' do
          subject.call('https://host.test/oembed.html', format: :xml)
          expect(subject.endpoint_url).to eq 'https://host.test/provider.xml'
          expect(subject.format).to eq :xml
        end
      end

      context 'JSON provider is discoverable while XML provider is not' do
        before do
          stub_request(:get, 'https://host.test/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_json.html')
          )
        end

        it 'returns new OEmbed::Provider for JSON provider' do
          subject.call('https://host.test/oembed.html')
          expect(subject.endpoint_url).to eq 'https://host.test/provider.json'
          expect(subject.format).to eq :json
        end
      end

      context 'XML provider is discoverable while JSON provider is not' do
        before do
          stub_request(:get, 'https://host.test/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_xml.html')
          )
        end

        it 'returns new OEmbed::Provider for XML provider' do
          subject.call('https://host.test/oembed.html')
          expect(subject.endpoint_url).to eq 'https://host.test/provider.xml'
          expect(subject.format).to eq :xml
        end
      end

      context 'Invalid XML provider is discoverable while JSON provider is not' do
        before do
          stub_request(:get, 'https://host.test/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_invalid_xml.html')
          )
        end

        it 'returns nil' do
          expect(subject.call('https://host.test/oembed.html')).to be_nil
        end
      end

      context 'Neither of JSON and XML provider is discoverable' do
        before do
          stub_request(:get, 'https://host.test/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_undiscoverable.html')
          )
        end

        it 'returns nil' do
          expect(subject.call('https://host.test/oembed.html')).to be_nil
        end
      end

      context 'Empty JSON provider is discoverable' do
        before do
          stub_request(:get, 'https://host.test/oembed.html').to_return(
            status: 200,
            headers: { 'Content-Type': 'text/html' },
            body: request_fixture('oembed_json_empty.html')
          )
        end

        it 'returns new OEmbed::Provider for JSON provider' do
          subject.call('https://host.test/oembed.html')
          expect(subject.endpoint_url).to eq 'https://host.test/empty_provider.json'
          expect(subject.format).to eq :json
        end
      end

    end

    context 'when status code is not 200' do
      before do
        stub_request(:get, 'https://host.test/oembed.html').to_return(
          status: 400,
          headers: { 'Content-Type': 'text/html' },
          body: request_fixture('oembed_xml.html')
        )
      end

      it 'returns nil' do
        expect(subject.call('https://host.test/oembed.html')).to be_nil
      end
    end

    context 'when MIME type is not text/html' do
      before do
        stub_request(:get, 'https://host.test/oembed.html').to_return(
          status: 200,
          body: request_fixture('oembed_xml.html')
        )
      end

      it 'returns nil' do
        expect(subject.call('https://host.test/oembed.html')).to be_nil
      end
    end
  end
end
