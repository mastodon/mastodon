# frozen_string_literal: true

class Mastodon::VapidKeyring
  delegate :public_key, to: :active_key, allow_nil: true

  def initialize(private_keys)
    @vapid_keys = private_keys.map { |skey| Webpush::VapidKey.from_keys(nil, skey) }
  end

  def active_key
    @vapid_keys.last
  end

  def lookup(server_key)
    if server_key.nil?
      active_key
    else
      @vapid_keys.find { |key| key.public_key == server_key }
    end
  end
end
