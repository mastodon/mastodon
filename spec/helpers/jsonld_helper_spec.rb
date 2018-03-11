# frozen_string_literal: true

require 'rails_helper'

describe JsonLdHelper do
  describe '#equals_or_includes?' do
    it 'returns true when value equals' do
      expect(helper.equals_or_includes?('foo', 'foo')).to be true
    end

    it 'returns false when value does not equal' do
      expect(helper.equals_or_includes?('foo', 'bar')).to be false
    end

    it 'returns true when value is included' do
      expect(helper.equals_or_includes?(%w(foo baz), 'foo')).to be true
    end

    it 'returns false when value is not included' do
      expect(helper.equals_or_includes?(%w(foo baz), 'bar')).to be false
    end
  end

  describe '#first_of_value' do
    pending
  end

  describe '#supported_context?' do
    pending
  end

  describe '#fetch_resource' do
    context 'when the second argument is false' do
      it 'returns resource even if the retrieved ID and the given URI does not match' do
        stub_request(:get, 'https://bob/').to_return body: '{"id": "https://alice/"}'
        stub_request(:get, 'https://alice/').to_return body: '{"id": "https://alice/"}'

        expect(fetch_resource('https://bob/', false)).to eq({ 'id' => 'https://alice/' })
      end

      it 'returns nil if the object identified by the given URI and the object identified by the retrieved ID does not match' do
        stub_request(:get, 'https://mallory/').to_return body: '{"id": "https://marvin/"}'
        stub_request(:get, 'https://marvin/').to_return body: '{"id": "https://alice/"}'

        expect(fetch_resource('https://mallory/', false)).to eq nil
      end
    end

    context 'when the second argument is true' do
      it 'returns nil if the retrieved ID and the given URI does not match' do
        stub_request(:get, 'https://mallory/').to_return body: '{"id": "https://alice/"}'
        expect(fetch_resource('https://mallory/', true)).to eq nil
      end
    end
  end

  describe '#fetch_resource_without_id_validation' do
    it 'returns nil if the status code is not 200' do
      stub_request(:get, 'https://host/').to_return status: 400, body: '{}'
      expect(fetch_resource_without_id_validation('https://host/')).to eq nil
    end

    it 'returns hash' do
      stub_request(:get, 'https://host/').to_return status: 200, body: '{}'
      expect(fetch_resource_without_id_validation('https://host/')).to eq({})
    end
  end

  describe '#find_href' do
    it 'returns href of Link with given rel' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/', 'rel' => 'self' }], 'self')).to eq 'https://example.com/'
    end

    it 'returns href of Link with rel array including given rel' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/', 'rel' => ['self'] }], 'self')).to eq 'https://example.com/'
    end

    it 'returns href of Link without rel' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/' }], 'self')).to eq 'https://example.com/'
    end

    it 'returns nil if Link with given rel is not found' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/', 'rel' => '' }], 'self')).to eq nil
    end

    it 'returns nil if only Link with rel whose type is invalid is given' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/', 'rel' => {} }], 'self')).to eq nil
    end

    it 'returns href of Link with given mime type' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/', 'mimeType' => 'text/html' }], nil, 'text/html')).to eq 'https://example.com/'
    end

    it 'returns href of Link with mime type array including given mime type' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/', 'mimeType' => ['text/html'] }], nil, 'text/html')).to eq 'https://example.com/'
    end

    it 'returns href of Link without mime type' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/' }], nil, 'text/html')).to eq 'https://example.com/'
    end

    it 'returns nil if Link with given mime type is not found' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/', 'mimeType' => '' }], nil, 'text/html')).to eq nil
    end

    it 'returns nil if only Link with mime type whose type is invalid is given' do
      expect(find_href([{ 'type' => 'Link', 'href' => 'https://example.com/', 'mimeType' => {} }], nil, 'text/html')).to eq nil
    end

    it 'returns string element' do
      expect(find_href(['https://example.com/'], 'self', 'text/html')).to eq 'https://example.com/'
    end

    it 'returns nil if only invalid object is given' do
      expect(find_href([{}])).to eq nil
    end
  end

  describe '#first_href' do
    it 'returns href given array' do
      expect(first_href(['https://example.com/'])).to eq 'https://example.com/'
    end

    it 'returns href given string' do
      expect(first_href('https://example.com/')).to eq 'https://example.com/'
    end

    it 'returns href given Link object' do
      expect(first_href({ 'type' => 'Link', 'href' => 'https://example.com/' })).to eq 'https://example.com/'
    end

    it 'returns nil given Link object with invalid href' do
      expect(first_href({ 'type' => 'Link', 'href' => {} })).to eq nil
    end
  end
end
