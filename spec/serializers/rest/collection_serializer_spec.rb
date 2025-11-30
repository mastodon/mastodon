# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::CollectionSerializer do
  subject { serialized_record_json(collection, described_class) }

  let(:collection) do
    Fabricate(:collection,
              name: 'Exquisite follows',
              description: 'Always worth a follow',
              local: true,
              sensitive: true,
              discoverable: false)
  end

  it 'includes the relevant attributes' do
    expect(subject)
      .to include(
        'account' => an_instance_of(Hash),
        'name' => 'Exquisite follows',
        'description' => 'Always worth a follow',
        'local' => true,
        'sensitive' => true,
        'discoverable' => false,
        'created_at' => match_api_datetime_format,
        'updated_at' => match_api_datetime_format
      )
  end
end
