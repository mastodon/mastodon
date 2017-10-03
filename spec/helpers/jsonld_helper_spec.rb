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
end
