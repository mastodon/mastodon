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

  let(:record) { PostStatusService.new.call(account, text: 'Status with special char tags #España') }
  let(:account) { Fabricate(:account) }

  describe 'tags' do
    it 'returns tags including special character versions of names and urls' do
      expect(serialization.deep_symbolize_keys)
        .to include(
          tags: contain_exactly(
            include(
              name: 'España',
              url: include('/tags/Espa%C3%B1a')
            )
          )
        )
    end
  end
end
