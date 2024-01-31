# frozen_string_literal: true

class InlineRenderer
  def initialize(object, current_account, template)
    @object          = object
    @current_account = current_account
    @template        = template
  end

  def render
    serializer = serializer_from_template
    return if serializer.nil?

    ActiveModelSerializers::SerializableResource.new(
      @object,
      serializer: serializer,
      scope: current_user,
      scope_name: :current_user
    ).as_json
  end

  def self.render(object, current_account, template)
    new(object, current_account, template).render
  end

  private

  def serializer_from_template
    case @template
    when :status
      preload_associations_for_status
      REST::StatusSerializer
    when :notification
      REST::NotificationSerializer
    when :conversation
      REST::ConversationSerializer
    when :announcement
      REST::AnnouncementSerializer
    when :reaction
      REST::ReactionSerializer
    when :encrypted_message
      REST::EncryptedMessageSerializer
    end
  end

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
