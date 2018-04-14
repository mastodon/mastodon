require 'chewy/search/pagination/kaminari_examples'

describe Chewy::Search::Pagination::Kaminari do
  it_behaves_like :kaminari, Chewy::Search::Request do
    describe '#objects' do
      let(:data) { Array.new(12) { |i| {id: i.next.to_s, name: "Name#{i.next}", age: 10 * i.next}.stringify_keys! } }

      before { ProductsIndex::Product.import!(data.map { |h| double(h) }) }
      before { allow(::Kaminari.config).to receive_messages(default_per_page: 17) }

      specify { expect(search.objects.class).to eq(Kaminari::PaginatableArray) }
      specify { expect(search.objects.total_count).to eq(12) }
      specify { expect(search.objects.limit_value).to eq(17) }
      specify { expect(search.objects.offset_value).to eq(0) }
      specify { expect(search.per(2).page(3).objects.class).to eq(Kaminari::PaginatableArray) }
      specify { expect(search.per(2).page(3).objects.total_count).to eq(12) }
      specify { expect(search.per(2).page(3).objects.limit_value).to eq(2) }
      specify { expect(search.per(2).page(3).objects.offset_value).to eq(4) }
    end
  end
end
