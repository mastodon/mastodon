require 'chewy/search/parameters/bool_storage_examples'

describe Chewy::Search::Parameters::TrackScores do
  it_behaves_like :bool_storage, :track_scores
end
