require 'spec_helper'

describe Chewy::Query::Nodes::Range do
  describe '#__render__' do
    def render(&block)
      Chewy::Query::Filters.new(&block).__render__
    end

    specify { expect(render { age > nil }).to eq(range: {'age' => {gt: nil}}) }
    specify { expect(render { age == (nil..nil) }).to eq(range: {'age' => {gt: nil, lt: nil}}) }

    specify { expect(render { age > 42 }).to eq(range: {'age' => {gt: 42}}) }
    specify { expect(render { age == (42..45) }).to eq(range: {'age' => {gt: 42, lt: 45}}) }
    specify { expect(render { age == [42..45] }).to eq(range: {'age' => {gte: 42, lte: 45}}) }
    specify { expect(render { (age > 42) & (age <= 45) }).to eq(range: {'age' => {gt: 42, lte: 45}}) }

    specify { expect(render { ~age > 42 }).to eq(range: {'age' => {gt: 42}, _cache: true}) }
    specify { expect(render { ~age == (42..45) }).to eq(range: {'age' => {gt: 42, lt: 45}, _cache: true}) }
    specify { expect(render { ~age == [42..45] }).to eq(range: {'age' => {gte: 42, lte: 45}, _cache: true}) }
    specify { expect(render { (age > 42) & ~(age <= 45) }).to eq(range: {'age' => {gt: 42, lte: 45}, _cache: true}) }
    specify { expect(render { (~age > 42) & (age <= 45) }).to eq(range: {'age' => {gt: 42, lte: 45}, _cache: true}) }

    specify { expect(render { age(:i) > 42 }).to eq(range: {'age' => {gt: 42}, execution: :index}) }
    specify { expect(render { age(:index) > 42 }).to eq(range: {'age' => {gt: 42}, execution: :index}) }
    specify { expect(render { age(:f) > 42 }).to eq(range: {'age' => {gt: 42}, execution: :fielddata}) }
    specify { expect(render { age(:fielddata) > 42 }).to eq(range: {'age' => {gt: 42}, execution: :fielddata}) }
    specify { expect(render { (age(:f) > 42) & (age <= 45) }).to eq(range: {'age' => {gt: 42, lte: 45}, execution: :fielddata}) }

    specify { expect(render { ~age(:f) > 42 }).to eq(range: {'age' => {gt: 42}, execution: :fielddata, _cache: true}) }
    specify { expect(render { (age(:f) > 42) & (~age <= 45) }).to eq(range: {'age' => {gt: 42, lte: 45}, execution: :fielddata, _cache: true}) }
  end
end
