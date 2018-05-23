require 'chewy/search/pagination/will_paginate_examples'

describe Chewy::Search::Pagination::WillPaginate do
  it_behaves_like :will_paginate, Chewy::Search::Request do
    describe '#objects' do
      let(:data) { Array.new(12) { |i| {id: i.next.to_s, name: "Name#{i.next}", age: 10 * i.next}.stringify_keys! } }

      before { ProductsIndex::Product.import!(data.map { |h| double(h) }) }
      before { allow(::WillPaginate).to receive_messages(per_page: 17) }

      # specify { expect(search.current_page).to eq(1) }
      # specify { expect(search.per_page).to eq(0) }
      specify { expect(search.objects.class).to eq(WillPaginate::Collection) }
      specify { expect(search.objects.total_entries).to eq(12) }
      specify { expect(search.objects.per_page).to eq(17) }
      specify { expect(search.objects.current_page).to eq(1) }
      specify { expect(search.paginate(per_page: 2, page: 3).objects.class).to eq(WillPaginate::Collection) }
      specify { expect(search.paginate(per_page: 2, page: 3).objects.total_entries).to eq(12) }
      specify { expect(search.paginate(per_page: 2, page: 3).objects.per_page).to eq(2) }
      specify { expect(search.paginate(per_page: 2, page: 3).objects.current_page).to eq(3) }
    end
  end
end
