require 'rails_helper'

RSpec.describe ActivityPub::Activity::Update do
  let!(:sender) { Fabricate(:account) }
  
  before do
    sender.update!(uri: ActivityPub::TagManager.instance.uri_for(sender))
  end

  let(:modified_sender) do 
    sender.dup.tap do |modified_sender|
      modified_sender.display_name = 'Totally modified now'
    end
  end

  let(:actor_json) do
    ActiveModelSerializers::SerializableResource.new(modified_sender, serializer: ActivityPub::ActorSerializer, key_transform: :camel_lower).as_json
  end

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Update',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: actor_json,
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    before do
      subject.perform
    end

    it 'updates profile' do
      expect(sender.reload.display_name).to eq 'Totally modified now'
    end
  end
end
