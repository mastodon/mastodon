# frozen_string_literal: true

require 'rails_helper'

describe REST::StatusSerializer do
  let(:serialization) { JSON.parse serialized_resource }
  let(:serialized_resource) do
    ActiveModelSerializers::SerializableResource.new(
      record,
      scope_name: :current_user,
      scope: nil,
      serializer: described_class
    ).to_json
  end

  let(:record) { Fabricate(:status, tags: tags) }
  let(:tag_names) { ['España', 'Test'] }
  let(:tags) { Tag.find_or_create_by_names(tag_names) }

  describe 'tags' do
    it 'returns tags including special characters' do
      expect(serialization.deep_symbolize_keys)
        .to include(
          tags: contain_exactly(
            include(name: 'España'),
            include(name: 'Test')
          )
        )
    end
  end
end
