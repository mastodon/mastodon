require 'chewy/search/parameters/hash_storage_examples'

describe Chewy::Search::Parameters::Aggs do
  it_behaves_like :hash_storage, :aggs
end
