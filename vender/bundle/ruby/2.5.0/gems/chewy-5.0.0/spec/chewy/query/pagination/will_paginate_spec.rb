require 'chewy/search/pagination/will_paginate_examples'

describe Chewy::Search::Pagination::WillPaginate do
  it_behaves_like :will_paginate, Chewy::Query
end
