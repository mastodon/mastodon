# frozen_string_literal: true

module Account::FollowerHashing
  extend ActiveSupport::Concern

  DIGEST_STYLE = 'H*'
  START_DIGEST = "\x00" * 32

  def remote_followers_hash(url)
    url_prefix = url[Account::URL_PREFIX_RE]
    return if url_prefix.blank?

    Rails.cache.fetch("followers_hash:#{id}:#{url_prefix}/") do
      digest_followers do |digest|
        followers.matches_uri_prefix(url_prefix).pluck_each(:uri) do |uri|
          digest_xor(digest, uri)
        end
      end
    end
  end

  def local_followers_hash
    Rails.cache.fetch("followers_hash:#{id}:local") do
      digest_followers do |digest|
        followers.local.pluck_each(:id_scheme, :id, :username) do |values|
          digest_xor(digest, local_follower_hash_uri(*values))
        end
      end
    end
  end

  private

  def local_follower_hash_uri(scheme, id, username)
    if scheme == 'numeric_ap_id'
      ActivityPub::TagManager.instance.uri_for_account_id(id)
    else
      ActivityPub::TagManager.instance.uri_for_username(username)
    end
  end

  def digest_followers(&block)
    START_DIGEST
      .dup
      .tap(&block)
      .unpack1(DIGEST_STYLE)
  end

  def digest_xor(digest, uri)
    Xorcist.xor!(digest, Digest::SHA256.digest(uri))
  end
end
