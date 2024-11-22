# frozen_string_literal: true

class InlineRenderer
  def initialize(object, current_account, template)
    @object          = object
    @current_account = current_account
    @template        = template
  end

  def render
    case @template
    when :status
      serializer = REST::StatusSerializer
      preload_associations_for_status
    when :notification
      serializer = REST::NotificationSerializer
    when :conversation
      serializer = REST::ConversationSerializer
    when :announcement
      serializer = REST::AnnouncementSerializer
    when :reaction
      serializer = REST::ReactionSerializer
    else
      return
    end

    serializable_resource = ActiveModelSerializers::SerializableResource.new(@object, serializer: serializer, scope: current_user, scope_name: :current_user)
    serializable_resource.as_json
  end

  def self.render(object, current_account, template)
    new(object, current_account, template).render
  end

  private

  def preload_associations_for_status
    ActiveRecord::Associations::Preloader.new(records: [@object], associations: {
      active_mentions: :account,

      reblog: {
        active_mentions: :account,
      },
    }).call
  end

  def current_user
    @current_account&.user
  end
end
