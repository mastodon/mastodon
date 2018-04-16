require 'chewy/search/parameters/bool_storage_examples'

describe Chewy::Search::Parameters::Explain do
  it_behaves_like :bool_storage, :explain
end
