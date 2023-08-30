# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::UpdatePollSerializer do
  subject { JSON.parse(@serialization.to_json) }

  let(:account) { Fabricate(:account) }
  let(:poll)    { Fabricate(:poll, account: account) }
  let!(:status) { Fabricate(:status, account: account, poll: poll) }

  before(:each) do
    @serialization = ActiveModelSerializers::SerializableResource.new(status, serializer: described_class, adapter: ActivityPub::Adapter)
  end

  it 'has a Update type' do
    expect(subject['type']).to eql('Update')
  end

  it 'has an object with Question type' do
    expect(subject['object']['type']).to eql('Question')
  end

  it 'has the correct actor URI set' do
    expect(subject['actor']).to eql(ActivityPub::TagManager.instance.uri_for(account))
  end
end
