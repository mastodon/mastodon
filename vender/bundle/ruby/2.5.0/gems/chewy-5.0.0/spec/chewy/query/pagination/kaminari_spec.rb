require 'chewy/search/pagination/kaminari_examples'

describe Chewy::Search::Pagination::Kaminari do
  it_behaves_like :kaminari, Chewy::Query
end
