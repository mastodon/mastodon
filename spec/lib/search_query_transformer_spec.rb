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
      ['"2024-10-31T23:47:20Z"', '2024-10-31T23:47:20Z'],
    ].each do |value, parsed|
      context "with \"foo #{operator}:#{value}\"" do
        let(:query) { "foo #{operator}:#{value}" }

        it 'transforms clauses' do
          ops = statement_operations.index_with { |_op| parsed }

          expect(subject.send(:must_clauses).map(&:term)).to contain_exactly('foo')
          expect(subject.send(:must_not_clauses)).to be_empty
          expect(subject.send(:filter_clauses).map(&:term)).to contain_exactly(**ops, time_zone: 'UTC')
        end
      end
    end

    context "with #{operator}:\"abc\"" do
      let(:query) { "#{operator}:\"abc\"" }

      it 'raises an exception' do
        expect { subject }.to raise_error(Date::Error)
      end
    end
  end

  context 'when there is no positive clause' do
    context 'with "-hello"' do
      let(:query) { '-hello' }

      it 'raises an exception' do
        expect { subject }.to raise_error(SearchQueryTransformer::QueryError)
      end
    end

    context 'with "after:0000"' do
      let(:query) { 'after:0000' }

      it 'raises an exception' do
        expect { subject }.to raise_error(SearchQueryTransformer::QueryError)
      end
    end

    context 'with "before:9999"' do
      let(:query) { 'before:9999' }

      it 'raises an exception' do
        expect { subject }.to raise_error(SearchQueryTransformer::QueryError)
      end
    end

    context 'with "is:reply"' do
      let(:query) { 'is:reply' }

      it 'raises an exception' do
        expect { subject }.to raise_error(SearchQueryTransformer::QueryError)
      end
    end

    context 'with \'is:reply " "\'' do
      let(:query) { 'is:reply " "' }

      it 'raises an exception' do
        expect { subject }.to raise_error(SearchQueryTransformer::QueryError)
      end
    end

    context 'with "in:library after:0000"' do
      let(:query) { 'in:library after:0000' }

      it 'does not raise an exception' do
        expect { subject }.to_not raise_error
      end
    end

    context 'with "from:me after:0000"' do
      let(:query) { 'from:me after:0000' }

      it 'does not raise an exception' do
        expect { subject }.to_not raise_error
      end
    end

    context 'with "from:me before:2026-08-28"' do
      let(:query) { 'from:me before:2026-08-28' }

      it 'does not raise an exception' do
        expect { subject }.to_not raise_error
      end
    end

    context 'with "from:me during:2024"' do
      let(:query) { 'from:me during:2024' }

      it 'does not raise an exception' do
        expect { subject }.to_not raise_error
      end
    end

    context 'with "from:<own username> after:0000"' do
      let(:query) { "from:#{account.username} after:0000" }

      it 'does not raise an exception' do
        expect { subject }.to_not raise_error
      end
    end

    context 'with "from:<own username>@<local domain> after:0000"' do
      let(:query) { "from:#{account.username}@#{Rails.configuration.x.local_domain} after:0000" }

      it 'does not raise an exception' do
        expect { subject }.to_not raise_error
      end
    end

    context 'with "from:<other user> after:0000"' do
      let(:other_account) { Fabricate(:account) }
      let(:query) { "from:#{other_account.username} after:0000" }

      it 'raises an exception' do
        expect { subject }.to raise_error(SearchQueryTransformer::QueryError)
      end
    end

    context 'with "from:<remote user> after:0000"' do
      let(:remote_account) { Fabricate(:account, domain: 'remote.host', username: 'remoteuser') }
      let(:query) { "from:#{remote_account.username}@#{remote_account.domain} after:0000" }

      it 'raises an exception' do
        expect { subject }.to raise_error(SearchQueryTransformer::QueryError)
      end
    end

    context 'with "-from:me after:0000"' do
      let(:query) { '-from:me after:0000' }

      it 'raises an exception' do
        expect { subject }.to raise_error(SearchQueryTransformer::QueryError)
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
      expect(subject.send(:must_clauses).map(&:term)).to contain_exactly('hello world')
      expect(subject.send(:must_not_clauses)).to be_empty
      expect(subject.send(:filter_clauses)).to be_empty
    end
  end

  context 'with \'foo is:"foo bar"\'' do
    let(:query) { 'foo is:"foo bar"' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses).map(&:term)).to contain_exactly('foo')
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

  context 'with multiple prefix clauses before a search term' do
    let(:query) { 'from:me has:media foo' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses).map(&:term)).to contain_exactly('foo')
      expect(subject.send(:must_not_clauses)).to be_empty
      expect(subject.send(:filter_clauses).map(&:prefix)).to contain_exactly('from', 'has')
    end
  end

  context 'with a search term between two prefix clauses' do
    let(:query) { 'from:me foo has:media' }

    it 'transforms clauses' do
      expect(subject.send(:must_clauses).map(&:term)).to contain_exactly('foo')
      expect(subject.send(:must_not_clauses)).to be_empty
      expect(subject.send(:filter_clauses).map(&:prefix)).to contain_exactly('from', 'has')
    end
  end
end
