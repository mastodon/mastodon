require 'spec_helper'

describe Chewy::Query::Nodes::Missing do
  describe '#__render__' do
    def render(&block)
      Chewy::Query::Filters.new(&block).__render__
    end

    specify { expect(render { !name }).to eq(missing: {field: 'name', existence: true, null_value: false}) }
    specify { expect(render { !name? }).to eq(missing: {field: 'name', existence: true, null_value: true}) }
    specify { expect(render { name == nil }).to eq(missing: {field: 'name', existence: false, null_value: true}) } # rubocop:disable Style/NilComparison
    specify { expect(render { name.nil? }).to eq(missing: {field: 'name', existence: false, null_value: true}) }

    specify { expect(render { ~!name }).to eq(missing: {field: 'name', existence: true, null_value: false}) }
  end
end
