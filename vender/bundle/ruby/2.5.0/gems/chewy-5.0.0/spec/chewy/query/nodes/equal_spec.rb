require 'spec_helper'

describe Chewy::Query::Nodes::Equal do
  describe '#__render__' do
    def render(&block)
      Chewy::Query::Filters.new(&block).__render__
    end

    specify { expect(render { name == 'name' }).to eq(term: {'name' => 'name'}) }
    specify { expect(render { name != 'name' }).to eq(not: {term: {'name' => 'name'}}) }
    specify { expect(render { name == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2]}) }
    specify { expect(render { name != %w[name1 name2] }).to eq(not: {terms: {'name' => %w[name1 name2]}}) }

    specify { expect(render { name(:bool) == 'name' }).to eq(term: {'name' => 'name'}) }
    specify { expect(render { name(:borogoves) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2]}) }

    specify { expect(render { name(:|) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2], execution: :or}) }
    specify { expect(render { name(:or) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2], execution: :or}) }
    specify { expect(render { name(:&) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2], execution: :and}) }
    specify { expect(render { name(:and) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2], execution: :and}) }
    specify { expect(render { name(:b) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2], execution: :bool}) }
    specify { expect(render { name(:bool) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2], execution: :bool}) }
    specify { expect(render { name(:f) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2], execution: :fielddata}) }
    specify { expect(render { name(:fielddata) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2], execution: :fielddata}) }

    specify { expect(render { ~name == 'name' }).to eq(term: {'name' => 'name', _cache: true}) }
    specify { expect(render { ~(name == 'name') }).to eq(term: {'name' => 'name', _cache: true}) }
    specify { expect(render { ~name != 'name' }).to eq(not: {term: {'name' => 'name', _cache: true}}) }
    specify { expect(render { ~name(:|) == %w[name1 name2] }).to eq(terms: {'name' => %w[name1 name2], execution: :or, _cache: true}) }
    specify { expect(render { ~name != %w[name1 name2] }).to eq(not: {terms: {'name' => %w[name1 name2], _cache: true}}) }
  end
end
