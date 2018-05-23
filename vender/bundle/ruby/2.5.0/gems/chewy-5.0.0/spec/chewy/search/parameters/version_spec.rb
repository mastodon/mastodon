require 'chewy/search/parameters/bool_storage_examples'

describe Chewy::Search::Parameters::Version do
  it_behaves_like :bool_storage, :version
end
