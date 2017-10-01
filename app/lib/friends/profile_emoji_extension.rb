# frozen_string_literal: true

module Friends
  module ProfileEmojiExtension
    extend ActiveSupport::Concern

    PROFILE_EMOJI_CACHE_TTL = 60.second
    PROFILE_EMOJI_RE = /:@(\w+):/.freeze
    IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

    def get_profile_emojis(text, key = nil, force: false)
      profile_emojis_json = Rails.cache.fetch(key, force: force, expires_in: PROFILE_EMOJI_CACHE_TTL) do
        scan_profile_emojis_from_text(text).to_json
      end

      profile_emojis = JSON.parse(profile_emojis_json, symbolize_names: true)

      return get_profile_emojis(text, key, force: true) if !force && updated_within_ttl?(profile_emojis)
      Account.where(id: profile_emojis.map{|x| x[:account_id] })
    end

    private

    def updated_within_ttl?(profile_emojis)
      profile_emojis.each do |profile_emoji|
        key = Friends::AvatarUpdateObserver::REDIS_FORMAT % profile_emoji[:shortcode]
        avatar_updated_at = Rails.cache.read(key)
        next if avatar_updated_at.nil?
        return true if avatar_updated_at.to_i - profile_emoji[:updated_at].to_i > 0
      end
      return false
    end

    def scan_profile_emojis_from_text(text)
      scaned_usernames = []
      text.scan(PROFILE_EMOJI_RE).map { |username|
        next if scaned_usernames.include? username
        a = Account.find_by(username: username)
        next if a.nil?
        scaned_usernames << username
        {
          account_id: a.id,
          updated_at: Time.now.utc.to_i,
        }
      }.compact
     end
  end
end
