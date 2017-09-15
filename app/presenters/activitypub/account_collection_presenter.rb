# frozen_string_literal: true

class ActivityPub::AccountCollectionPresenter < ActiveModelSerializers::Model
  attributes :account, :scope
end
