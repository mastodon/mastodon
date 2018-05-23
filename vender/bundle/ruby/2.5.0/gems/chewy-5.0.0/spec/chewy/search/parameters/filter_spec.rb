require 'chewy/search/parameters/query_storage_examples'

describe Chewy::Search::Parameters::Filter do
  it_behaves_like :query_storage, :filter
end
