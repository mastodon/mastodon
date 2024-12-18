# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchQueryTransformer do
  subject { described_class.new.apply(parser, current_account: account) }

  let(:account) { Fabricate(:account) }
  let(:parser) { SearchQueryParser.new.parse(query) }

  shared_examples 'date operator' do |operator|
    let(:statement_operations) { [] }

    [
      ['2022-01-01', '2022-01-01'],
      ['"2022-01-01"', '2022-01-01'],
      ['12345678', '12345678'],
      ['"12345678"', '12345678'],
    ].each do |value, parsed|
      context "with #{operator}:#{value}" do
        let(:query) { "#{operator}:#{value}" }

        it 'transforms clauses' do
          ops = statement_operations.index_with { |_op| parsed }

          expect(subject.send(:must_clauses)).to be_empty
          expect(subject.send(:must_not_clauses)).to be_empty
          expect(subject.send(:filter_clauses).map(&:term)).to contain_exactly(**ops, time_zone: 'UTC')
        end
      end
    end

    context "with #{operator}:\"abc\"" do
      let(:query) { "#{operator}:\"abc\"" }

      it 'raises an exception' do
        expect { subject }.to raise_error(Mastodon::FilterValidationError, 'Invalid date abc')
      end
    end
  end

  context 'with "hello world"' do
    let(:query) { 'hello world' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses).map(&:term)).to match_array %w(hello world)
      expect(subject.send(:must_not_clauses)).to be_empty
      expect(subject.send(:filter_clauses)).to be_empty
    end
  end

  context 'with "hello -world"' do
    let(:query) { 'hello -world' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses).map(&:term)).to match_array %w(hello)
      expect(subject.send(:must_not_clauses).map(&:term)).to match_array %w(world)
      expect(subject.send(:filter_clauses)).to be_empty
    end
  end

  context 'with "hello is:reply"' do
    let(:query) { 'hello is:reply' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses).map(&:term)).to match_array %w(hello)
      expect(subject.send(:must_not_clauses)).to be_empty
      expect(subject.send(:filter_clauses).map(&:term)).to match_array %w(reply)
    end
  end

  context 'with "foo: bar"' do
    let(:query) { 'foo: bar' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses).map(&:term)).to match_array %w(foo bar)
      expect(subject.send(:must_not_clauses)).to be_empty
      expect(subject.send(:filter_clauses)).to be_empty
    end
  end

  context 'with "foo:bar"' do
    let(:query) { 'foo:bar' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses).map(&:term)).to contain_exactly('foo bar')
      expect(subject.send(:must_not_clauses)).to be_empty
      expect(subject.send(:filter_clauses)).to be_empty
    end
  end

  context 'with \'"hello world"\'' do
    let(:query) { '"hello world"' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses).map(&:phrase)).to contain_exactly('hello world')
      expect(subject.send(:must_not_clauses)).to be_empty
      expect(subject.send(:filter_clauses)).to be_empty
    end
  end

  context 'with \'is:"foo bar"\'' do
    let(:query) { 'is:"foo bar"' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses)).to be_empty
      expect(subject.send(:must_not_clauses)).to be_empty
      expect(subject.send(:filter_clauses).map(&:term)).to contain_exactly('foo bar')
    end
  end

  context 'with date operators' do
    context 'with "before"' do
      it_behaves_like 'date operator', 'before' do
        let(:statement_operations) { [:lt] }
      end
    end

    context 'with "after"' do
      it_behaves_like 'date operator', 'after' do
        let(:statement_operations) { [:gt] }
      end
    end

    context 'with "during"' do
      it_behaves_like 'date operator', 'during' do
        let(:statement_operations) { [:gte, :lte] }
      end
    end
  end
end
