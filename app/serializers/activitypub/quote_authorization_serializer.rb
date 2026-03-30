# frozen_string_literal: true

class ActivityPub::QuoteAuthorizationSerializer < ActivityPub::Serializer
  include RoutingHelper

  context_extensions :quote_authorizations

  attributes :id, :type, :attributed_to, :interacting_object, :interaction_target

  def id
    ActivityPub::TagManager.instance.approval_uri_for(object, check_approval: !instance_options[:force_approval_id])
  end

  def type
    'QuoteAuthorization'
  end

  def attributed_to
    ActivityPub::TagManager.instance.uri_for(object.quoted_account)
  end

  def interaction_target
    ActivityPub::TagManager.instance.uri_for(object.quoted_status)
  end

  def interacting_object
    ActivityPub::TagManager.instance.uri_for(object.status)
  end
end
