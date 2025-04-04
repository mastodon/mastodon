# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::QuoteSerializer do
  subject do
    serialized_record_json(
      quote,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:quote) { Fabricate(:quote) }

  it 'returns expected values' do
    expect(subject.deep_symbolize_keys)
      .to include(
        quoted_status: be_a(Hash),
        state: 'pending'
      )
  end
end
