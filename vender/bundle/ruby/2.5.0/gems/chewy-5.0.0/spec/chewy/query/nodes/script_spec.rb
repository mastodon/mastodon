require 'spec_helper'

describe Chewy::Query::Nodes::Script do
  describe '#__render__' do
    def render(&block)
      Chewy::Query::Filters.new(&block).__render__
    end

    specify { expect(render { s('var = val') }).to eq(script: {script: 'var = val'}) }
    specify { expect(render { s('var = val', val: 42) }).to eq(script: {script: 'var = val', params: {val: 42}}) }

    specify { expect(render { ~s('var = val') }).to eq(script: {script: 'var = val', _cache: true}) }
    specify { expect(render { ~s('var = val', val: 42) }).to eq(script: {script: 'var = val', params: {val: 42}, _cache: true}) }
  end
end
