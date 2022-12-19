class FilterResultPresenter < ActiveModelSerializers::Model
  attributes :filter, :keyword_matches, :status_matches
end
