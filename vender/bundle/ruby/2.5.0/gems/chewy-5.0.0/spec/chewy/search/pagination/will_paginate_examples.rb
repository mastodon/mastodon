require 'spec_helper'

shared_examples :will_paginate do |request_base_class|
  before { Chewy.massacre }

  before do
    stub_index(:products) do
      define_type(:product) do
        field :name
        field :age, type: 'integer'
      end
    end
  end

  let(:except_fields) { %w[_score _explanation] }
  let(:request_class) do
    Class.new(request_base_class).tap do |k|
      k.include Chewy::Search::Pagination::WillPaginate
    end
  end
  let(:search) { request_class.new(ProductsIndex).order(:age) }

  specify { expect(search.total_pages).to eq(1) } # defaults to 1 on will_paginate

  context do
    let(:data) { Array.new(10) { |i| {id: i.next.to_s, name: "Name#{i.next}", age: 10 * i.next}.stringify_keys! } }

    before { ProductsIndex::Product.import!(data.map { |h| double(h) }) }
    before { allow(::WillPaginate).to receive_messages(per_page: 3) }

    describe '#page' do
      specify { expect(search.map { |e| e.attributes.except(*except_fields) }).to match_array(data) }
      specify { expect(search.page(1).map { |e| e.attributes.except(*except_fields) }).to eq(data[0..2]) }
      specify { expect(search.page(2).map { |e| e.attributes.except(*except_fields) }).to eq(data[3..5]) }
    end

    describe '#paginate' do
      specify { expect(search.paginate(page: 2, per_page: 4).map { |e| e.attributes.except(*except_fields) }).to eq(data[4..7]) }
      specify { expect(search.paginate(per_page: 2, page: 3).page(3).map { |e| e.attributes.except(*except_fields) }).to eq(data[4..5]) }
      specify { expect(search.paginate(per_page: 5).map { |e| e.attributes.except(*except_fields) }).to eq(data[0..4]) }
      specify { expect(search.paginate(per_page: 4).map { |e| e.attributes.except(*except_fields) }).to eq(data[0..3]) }
    end

    describe '#total_pages' do
      specify { expect(search.paginate(page: 2, per_page: 5).total_pages).to eq(2) }
      specify { expect(search.paginate(page: 3, per_page: 2).total_pages).to eq(5) }
    end

    describe '#total_entries' do
      specify { expect(search.paginate(page: 1, per_page: 4).total_entries).to eq(10) }
      specify { expect(search.query(range: {age: {gt: 20}}).limit(3).total_entries).to eq(8) }
    end

    describe '#load' do
      specify { expect(search.paginate(per_page: 2, page: 1).load.first.age).to eq(10) }
      specify { expect(search.paginate(per_page: 2, page: 3).load.first.age).to eq(50) }
      specify { expect(search.paginate(per_page: 2, page: 3).load.page(2).load.first.age).to eq(30) }

      specify { expect(search.paginate(per_page: 4, page: 1).load.total_count).to eq(10) }
      specify { expect(search.paginate(per_page: 2, page: 3).load.total_pages).to eq(5) }
    end
  end
end
