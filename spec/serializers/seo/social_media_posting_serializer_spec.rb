# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SEO::SocialMediaPostingSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate :status }

  describe 'Serialization' do
    it 'serialized expected values' do
      expect(subject['type'])
        .to eq('SocialMediaPosting')
    end
  end
end
