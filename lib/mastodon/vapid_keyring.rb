# frozen_string_literal: true

class Mastodon::VapidKeyring
  delegate :public_key, :private_key, to: :active_key, allow_nil: true

  def initialize(private_keys)
    @vapid_keys = private_keys.map { |skey| Webpush::VapidKey.from_keys(nil, skey) }
  end

  def active_key
    @vapid_keys.last
  end
end
