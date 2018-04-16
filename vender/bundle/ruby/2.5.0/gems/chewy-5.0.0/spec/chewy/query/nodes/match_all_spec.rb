require 'spec_helper'

describe Chewy::Query::Nodes::MatchAll do
  describe '#__render__' do
    def render(&block)
      Chewy::Query::Filters.new(&block).__render__
    end

    specify { expect(render { match_all }).to eq(match_all: {}) }
  end
end
