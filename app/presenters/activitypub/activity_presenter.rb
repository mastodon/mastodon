# frozen_string_literal: true

class ActivityPub::ActivityPresenter < ActiveModelSerializers::Model
  attributes :id, :type, :actor, :published, :to, :cc, :virtual_object

  class << self
    def from_status(status, allow_inlining: true)
      new.tap do |presenter|
        presenter.id        = ActivityPub::TagManager.instance.activity_uri_for(status)
        presenter.type      = status.reblog? ? 'Announce' : 'Create'
        presenter.actor     = ActivityPub::TagManager.instance.uri_for(status.account)
        presenter.published = status.created_at
        presenter.to        = ActivityPub::TagManager.instance.to(status)
        presenter.cc        = ActivityPub::TagManager.instance.cc(status)

        presenter.virtual_object = begin
          if status.reblog?
            if allow_inlining && status.account == status.proper.account && status.proper.private_visibility? && status.local?
              status.proper
            else
              ActivityPub::TagManager.instance.uri_for(status.proper)
            end
          else
            status.proper
          end
        end
      end
    end
  end
end
