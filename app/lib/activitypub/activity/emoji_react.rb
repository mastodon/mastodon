# frozen_string_literal: true

class ActivityPub::Activity::EmojiReact < ActivityPub::Activity
  def perform
    original_status = status_from_uri(object_uri)

    return if original_status.nil? || !original_status.account.local? || delete_arrived_first?(@json['id']) || @account.reacted?(original_status, @json['content'])

    reaction = original_status.emoji_reactions.create!(account: @account, name: @json['content'])
    #TODO: NotifyService.new.call(original_status.account, reaction)
  end
end
