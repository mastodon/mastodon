# frozen_string_literal: true

# Paths handled by the React application, which do not:
# - Require indexing
# - Have alternative format representations

%w(
  /blocks
  /bookmarks
  /collections/(*any)
  /conversations
  /deck/(*any)
  /directory
  /domain_blocks
  /explore/(*any)
  /favourites
  /follow_requests
  /followed_tags
  /getting-started
  /home
  /keyboard-shortcuts
  /links/(*any)
  /lists/(*any)
  /mutes
  /notifications_v2/(*any)
  /notifications/(*any)
  /pinned
  /profile/(*any)
  /public
  /public/local
  /public/remote
  /publish
  /search
  /start/(*any)
  /statuses/(*any)
).each { |path| get path, to: 'home#index' }
