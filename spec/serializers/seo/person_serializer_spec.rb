# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SEO::PersonSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate :account }

  describe 'Serialization' do
    it 'serialized expected values' do
      expect(subject['type'])
        .to eq('Person')
    end
  end
end
