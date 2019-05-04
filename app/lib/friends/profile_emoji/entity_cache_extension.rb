module Friends
  module ProfileEmoji
    module EntityCacheExtension
      extend ActiveSupport::Concern

      def avatar(username, domain)
        Rails.cache.fetch(to_key(:avatar, username, domain), expires_in: EntityCache::MAX_EXPIRATION) { Account.select(:id, :username, :domain, :avatar_file_name).find_remote(username, domain) }
      end
    end
  end
end
