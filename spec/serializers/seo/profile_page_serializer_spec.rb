# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SEO::ProfilePageSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate :account }

  describe 'Serialization' do
    it 'serialized expected values' do
      expect(subject['type'])
        .to eq('ProfilePage')
    end
  end
end
