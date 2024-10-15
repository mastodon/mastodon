# frozen_string_literal: true

class ActivityPub::Activity::Like < ActivityPub::Activity
  def perform
    original_status = status_from_uri(object_uri)

    return if original_status.nil? || !original_status.account.local? || delete_arrived_first?(@json['id']) || @account.favourited?(original_status)

    process_custom_emoji

    favourite = original_status.favourites.create!(account: @account, custom_emoji: @custom_emoji, emoji: @json['content'])

    LocalNotificationWorker.perform_async(original_status.account_id, favourite.id, 'Favourite', 'favourite')
    Trends.statuses.register(original_status)
  end

  private

  # originally, copied from ActivityPub::Activity::Create
  def process_custom_emoji
    # see https://scrapbox.io/activitypub/%E7%B5%B5%E6%96%87%E5%AD%97%E3%83%AA%E3%82%A2%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3
    content = @json['content']
    return unless content&.start_with?(':') && content&.end_with?(':')

    shortcode = content.delete(':')
    @custom_emoji = CustomEmoji.find_by(shortcode: shortcode, domain: @account.domain)
    # Abort here if the custom_emoji is already registered.
    # ActivityPub::Activity::Create updates staled CustomEmoji, but we do not update CustomEmoji here.
    return if @custom_emoji

    image_url = @json.dig('tag', 0, 'icon', 'url')
    @custom_emoji = CustomEmoji.new(domain: @account.domain, shortcode: shortcode, uri: image_url, image_remote_url: image_url)
    @custom_emoji.save!
  end
end
