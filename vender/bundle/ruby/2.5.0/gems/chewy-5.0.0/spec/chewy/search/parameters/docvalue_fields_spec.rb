require 'chewy/search/parameters/string_array_storage_examples'

describe Chewy::Search::Parameters::DocvalueFields do
  it_behaves_like :string_array_storage, :docvalue_fields
end
