require 'spec_helper'

describe Chewy::Query::Nodes::Exists do
  describe '#__render__' do
    def render(&block)
      Chewy::Query::Filters.new(&block).__render__
    end

    specify { expect(render { name? }).to eq(exists: {field: 'name'}) }

    specify { expect(render { !!name? }).to eq(exists: {field: 'name'}) }
    specify { expect(render { !!name }).to eq(exists: {field: 'name'}) }
    specify { expect(render { name != nil }).to eq(exists: {field: 'name'}) } # rubocop:disable Style/NonNilCheck
    specify { expect(render { !name.nil? }).to eq(exists: {field: 'name'}) }

    specify { expect(render { ~name? }).to eq(exists: {field: 'name'}) }
  end
end
