# frozen_string_literal: true

class ActivityPub::SynchronizationItemPresenter < ActiveModelSerializers::Model
  attributes :account, :domain, :digest
end
