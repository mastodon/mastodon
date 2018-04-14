require 'chewy/search/parameters/integer_storage_examples'

describe Chewy::Search::Parameters::TerminateAfter do
  it_behaves_like :integer_storage, :terminate_after
end
