require 'chewy/search/parameters/hash_storage_examples'

describe Chewy::Search::Parameters::Suggest do
  it_behaves_like :hash_storage, :suggest
end
