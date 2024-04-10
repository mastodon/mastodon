# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::NoteSerializer do
  let!(:account) { Fabricate(:account) }
  let!(:other)   { Fabricate(:account) }
  let!(:parent)  { Fabricate(:status, account: account, media_attachments: [Fabricate(:media_attachment)]) }
  let!(:reply1)  { Fabricate(:status, account: account, thread: parent) }
  let!(:reply2)  { Fabricate(:status, account: account, thread: parent) }
  let!(:reply3)  { Fabricate(:status, account: other, thread: parent) }
  let!(:reply4)  { Fabricate(:status, account: account, thread: parent) }
  let!(:reply5)  { Fabricate(:status, account: account, thread: parent, visibility: :direct) }

  before(:each) do
    @serialization = ActiveModelSerializers::SerializableResource.new(parent, serializer: ActivityPub::NoteSerializer, adapter: ActivityPub::Adapter)
  end

  subject { JSON.parse(@serialization.to_json) }

  it 'has a Note type' do
    expect(subject['type']).to eql('Note')
  end

  it 'has a replies collection' do
    expect(subject['replies']['type']).to eql('Collection')
  end

  it 'has a replies collection with a first Page' do
    expect(subject['replies']['first']['type']).to eql('CollectionPage')
  end

  it 'includes public self-replies in its replies collection' do
    expect(subject['replies']['first']['items']).to include(reply1.uri, reply2.uri, reply4.uri)
  end

  it 'does not include replies from others in its replies collection' do
    expect(subject['replies']['first']['items']).to_not include(reply3.uri)
  end

  it 'does not include replies with direct visibility in its replies collection' do
    expect(subject['replies']['first']['items']).to_not include(reply5.uri)
  end

  it 'returns media attachments with short urls' do
    expect(subject['attachment']).to be_kind_of(Array)
    expect(subject['attachment'].first['url']).to match(%r{media\/short\/\d+\/original})
  end
end
