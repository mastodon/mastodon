require 'spec_helper'

describe Chewy::Query::Pagination do
  if Chewy::Runtime.version < '5.0'
    before { Chewy.massacre }

    before do
      stub_index(:products) do
        define_type(:product) do
          field :name
          field :age, type: 'integer'
        end
      end
    end

    let(:search) { Chewy::Query.new(ProductsIndex).order(:age) }

    specify { expect(search.total_count).to eq(0) }

    context do
      let(:data) { Array.new(10) { |i| {id: i.next.to_s, name: "Name#{i.next}", age: 10 * i.next}.stringify_keys! } }

      before { ProductsIndex::Product.import!(data.map { |h| double(h) }) }

      describe '#total_count' do
        specify { expect(search.total_count).to eq(10) }
        specify { expect(search.limit(5).total_count).to eq(10) }
        specify { expect(search.filter(range: {age: {gt: 20}}).limit(3).total_count).to eq(8) }
      end

      describe '#load' do
        specify { expect(search.load.total_count).to eq(10) }
        specify { expect(search.limit(5).load.total_count).to eq(10) }
      end
    end
  else
    xspecify 'Skip Chewy::Query specs for 5.0'
  end
end
