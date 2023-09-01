# frozen_string_literal: true

require 'rails_helper'

describe SearchQueryTransformer do
  subject { described_class.new.apply(parser, current_account: nil) }

  let(:parser) { SearchQueryParser.new.parse(query) }

  context 'with "hello world"' do
    let(:query) { 'hello world' }

    it 'transforms clauses' do
      expect(subject.must_clauses.map(&:term)).to match_array %w(hello world)
      expect(subject.must_not_clauses).to be_empty
      expect(subject.filter_clauses).to be_empty
    end
  end

  context 'with "hello -world"' do
    let(:query) { 'hello -world' }

    it 'transforms clauses' do
      expect(subject.must_clauses.map(&:term)).to match_array %w(hello)
      expect(subject.must_not_clauses.map(&:term)).to match_array %w(world)
      expect(subject.filter_clauses).to be_empty
    end
  end

  context 'with "hello is:reply"' do
    let(:query) { 'hello is:reply' }

    it 'transforms clauses' do
      expect(subject.must_clauses.map(&:term)).to match_array %w(hello)
      expect(subject.must_not_clauses).to be_empty
      expect(subject.filter_clauses.map(&:term)).to match_array %w(reply)
    end
  end

  context 'with "foo: bar"' do
    let(:query) { 'foo: bar' }

    it 'transforms clauses' do
      expect(subject.must_clauses.map(&:term)).to match_array %w(foo bar)
      expect(subject.must_not_clauses).to be_empty
      expect(subject.filter_clauses).to be_empty
    end
  end

  context 'with "foo:bar"' do
    let(:query) { 'foo:bar' }

    it 'transforms clauses' do
      expect(subject.must_clauses.map(&:term)).to contain_exactly('foo bar')
      expect(subject.must_not_clauses).to be_empty
      expect(subject.filter_clauses).to be_empty
    end
  end
end
