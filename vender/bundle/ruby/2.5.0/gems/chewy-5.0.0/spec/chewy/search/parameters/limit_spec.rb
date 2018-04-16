require 'chewy/search/parameters/integer_storage_examples'

describe Chewy::Search::Parameters::Limit do
  it_behaves_like :integer_storage, :size
end
