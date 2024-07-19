# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagSearchService do
  describe '#call' do
    let!(:one) { Fabricate(:tag, name: 'one') }

    before { Fabricate(:tag, name: 'two') }

    it 'runs a search for tags' do
      results = subject.call('#one', limit: 5)

      expect(results)
        .to have_attributes(
          size: 1,
          first: eq(one)
        )
    end
  end
end
