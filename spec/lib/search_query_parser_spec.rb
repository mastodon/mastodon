# frozen_string_literal: true

require 'rails_helper'
require 'parslet/rig/rspec'

RSpec.describe SearchQueryParser do
  let(:parser) { described_class.new }

  context 'with term' do
    it 'consumes "hello"' do
      expect(parser.term).to parse('hello')
    end
  end

  context 'with prefix' do
    it 'consumes "foo:"' do
      expect(parser.prefix).to parse('foo:')
    end
  end

  context 'with operator' do
    it 'consumes "+"' do
      expect(parser.operator).to parse('+')
    end

    it 'consumes "-"' do
      expect(parser.operator).to parse('-')
    end
  end

  context 'with shortcode' do
    it 'consumes ":foo:"' do
      expect(parser.shortcode).to parse(':foo:')
    end
  end

  context 'with phrase' do
    it 'consumes "hello world"' do
      expect(parser.phrase).to parse('"hello world"')
    end
  end

  context 'with clause' do
    it 'consumes "foo"' do
      expect(parser.clause).to parse('foo')
    end

    it 'consumes "-foo"' do
      expect(parser.clause).to parse('-foo')
    end

    it 'consumes "foo:bar"' do
      expect(parser.clause).to parse('foo:bar')
    end

    it 'consumes "-foo:bar"' do
      expect(parser.clause).to parse('-foo:bar')
    end

    it 'consumes \'foo:"hello world"\'' do
      expect(parser.clause).to parse('foo:"hello world"')
    end

    it 'consumes \'-foo:"hello world"\'' do
      expect(parser.clause).to parse('-foo:"hello world"')
    end

    it 'consumes "foo:"' do
      expect(parser.clause).to parse('foo:')
    end

    it 'consumes \'"\'' do
      expect(parser.clause).to parse('"')
    end
  end

  context 'with query' do
    it 'consumes "hello -world"' do
      expect(parser.query).to parse('hello -world')
    end

    it 'consumes \'foo "hello world"\'' do
      expect(parser.query).to parse('foo "hello world"')
    end

    it 'consumes "foo:bar hello"' do
      expect(parser.query).to parse('foo:bar hello')
    end

    it 'consumes \'"hello" world "\'' do
      expect(parser.query).to parse('"hello" world "')
    end

    it 'consumes "foo:bar bar: hello"' do
      expect(parser.query).to parse('foo:bar bar: hello')
    end
  end
end
