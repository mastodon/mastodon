class FeedManager
  MAX_ITEMS = 800

  def self.key(type, id)
    "feed:#{type}:#{id}"
  end

  def self.filter_status?(status, follower)
    (status.reply? && !(follower.id = replied_to_user.id || follower.following?(replied_to_user)))
  end
end
