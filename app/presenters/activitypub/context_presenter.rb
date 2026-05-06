# frozen_string_literal: true

class ActivityPub::ContextPresenter < ActiveModelSerializers::Model
  attributes :id, :type, :attributed_to, :first, :object_type

  class << self
    def from_conversation(conversation)
      new.tap do |presenter|
        presenter.id = ActivityPub::TagManager.instance.uri_for(conversation)
        presenter.attributed_to = ActivityPub::TagManager.instance.uri_for(conversation.parent_account) if conversation.parent_account.present?
      end
    end
  end
end
