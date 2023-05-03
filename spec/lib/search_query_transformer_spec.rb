# frozen_string_literal: true

require 'rails_helper'

describe SearchQueryTransformer do
  describe 'initialization' do
    let(:parser) { SearchQueryParser.new.parse('query') }

    it 'sets attributes' do
      transformer = described_class.new.apply(parser)

      expect(transformer.should_clauses.first).to be_a(SearchQueryTransformer::TermClause)
      expect(transformer.must_clauses.first).to be_nil
      expect(transformer.must_not_clauses.first).to be_nil
      expect(transformer.filter_clauses.first).to be_nil
    end
  end
end
