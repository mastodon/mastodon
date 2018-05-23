require 'chewy/search/parameters/string_storage_examples'

describe Chewy::Search::Parameters::Timeout do
  it_behaves_like :string_storage, :timeout
end
