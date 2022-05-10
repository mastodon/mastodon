# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::ActorSerializer do
  subject(:json) do
    JSON.parse(ActiveModelSerializers::SerializableResource.new(account, serializer: described_class, adapter: ActivityPub::Adapter).to_json)
  end

  subject(:compacted) { JSON::LD::API.compact(json.deep_dup, nil) }

  let(:account) { Fabricate(:account, fields: [{ name: 'foo', value: 'bar' }]) }

  it 'has a Person type' do
    expect(json['type']).to eql('Person')
  end

  it 'has the correct actor URI set' do
    expect(json['id']).to eql(ActivityPub::TagManager.instance.uri_for(account))
  end

  it 'outputs profile fields in a way readable in JSON' do
    expect(json['attachment'].filter_map do |attachment|
      [attachment['name'], attachment['value']] if attachment['type'] == 'PropertyValue'
    end).to eq [['foo', 'bar']]
  end

  it 'outputs profile fields in a way that is correct JSON-LD' do
    expect(compacted['https://www.w3.org/ns/activitystreams#attachment'].filter_map do |attachment|
      [attachment['http://schema.org/name'], attachment['http://schema.org/value']] if attachment['@type'] == 'http://schema.org/PropertyValue'
    end).to eq [['foo', 'bar']]
  end

  it 'outputs profile fields in a way that older Mastodon versions support' do
    expect(compacted['https://www.w3.org/ns/activitystreams#attachment'].filter_map do |attachment|
      [attachment['https://www.w3.org/ns/activitystreams#name'], attachment['http://schema.org#value']] if attachment['@type'] == 'http://schema.org#PropertyValue'
    end).to eq [['foo', 'bar']]
  end
end
