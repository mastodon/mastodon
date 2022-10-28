# frozen_string_literal: true

class FilterResultPresenter < ActiveModelSerializers::Model
  attributes :filter, :keyword_matches, :status_matches
end
