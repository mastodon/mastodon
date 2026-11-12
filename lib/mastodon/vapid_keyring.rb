# frozen_string_literal: true

class Mastodon::VapidKeyring
  delegate :public_key, to: :active_key, allow_nil: true

  def initialize(inactive_keys, active_key)
    @vapid_keys = inactive_keys.map { |skey| Webpush::VapidKey.from_keys(nil, skey) }
      .push(active_key.nil? ? nil : Webpush::VapidKey.from_keys(nil, active_key))
      .freeze
  end

  def active_key
    @vapid_keys.last
  end

  def lookup(server_key)
    if server_key.nil?
      active_key
    else
      @vapid_keys.find { |key| key&.public_key == server_key }
    end
  end
end
