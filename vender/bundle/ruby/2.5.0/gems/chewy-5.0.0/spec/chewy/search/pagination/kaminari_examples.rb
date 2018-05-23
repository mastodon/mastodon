require 'spec_helper'

shared_examples :kaminari do |request_base_class|
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
      k.include Chewy::Search::Pagination::Kaminari
    end
  end
  let(:search) { request_class.new(ProductsIndex).order(:age) }

  specify { expect(search.total_pages).to eq(0) }

  context do
    let(:data) { Array.new(10) { |i| {id: i.next.to_s, name: "Name#{i.next}", age: 10 * i.next}.stringify_keys! } }

    before { ProductsIndex::Product.import!(data.map { |h| double(h) }) }
    before { allow(::Kaminari.config).to receive_messages(default_per_page: 3) }

    describe '#per, #page' do
      specify { expect(search.map { |e| e.attributes.except(*except_fields) }).to match_array(data) }
      specify { expect(search.page(1).map { |e| e.attributes.except(*except_fields) }).to eq(data[0..2]) }
      specify { expect(search.page(2).map { |e| e.attributes.except(*except_fields) }).to eq(data[3..5]) }
      specify { expect(search.page(2).per(4).map { |e| e.attributes.except(*except_fields) }).to eq(data[4..7]) }
      specify { expect(search.per(2).page(3).map { |e| e.attributes.except(*except_fields) }).to eq(data[4..5]) }
      specify { expect(search.per(5).page.map { |e| e.attributes.except(*except_fields) }).to eq(data[0..4]) }
      specify { expect(search.page.per(4).map { |e| e.attributes.except(*except_fields) }).to eq(data[0..3]) }
    end

    describe '#total_pages' do
      specify { expect(search.total_pages).to eq(4) }
      specify { expect(search.per(5).page(2).total_pages).to eq(2) }
      specify { expect(search.per(2).page(3).total_pages).to eq(5) }
    end

    describe '#total_count' do
      specify { expect(search.per(4).page(1).total_count).to eq(10) }
      specify { expect(search.query(range: {age: {gt: 20}}).limit(3).total_count).to eq(8) }
    end

    describe '#load' do
      specify { expect(search.per(2).page(1).load.first.age).to eq(10) }
      specify { expect(search.per(2).page(3).load.first.age).to eq(50) }
      specify { expect(search.per(2).page(3).load.page(2).load.first.age).to eq(30) }

      specify { expect(search.per(4).page(1).load.total_count).to eq(10) }
      specify { expect(search.per(2).page(3).load.total_pages).to eq(5) }
    end

    describe '#limit_value' do
      specify { expect(search.limit_value).to eq(3) }
      specify { expect(search.per(15).limit_value).to eq(15) }
    end

    describe '#offset_value' do
      specify { expect(search.offset_value).to eq(0) }
      specify { expect(search.page(3).offset_value).to eq(6) }
    end
  end
end
