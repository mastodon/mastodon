# frozen_string_literal: true

class FilterResultPresenter < ActiveModelSerializers::Model
  attributes :filter, :account_matches, :keyword_matches, :status_matches
end
