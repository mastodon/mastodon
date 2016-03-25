class FeedManager
  MAX_ITEMS = 800

  def self.key(type, id)
    "feed:#{type}:#{id}"
  end

  def self.filter_status?(status, follower)
    replied_to_user = status.reply? ? status.thread.account : nil
    (status.reply? && !(follower.id = replied_to_user.id || follower.following?(replied_to_user)))
  end
end
