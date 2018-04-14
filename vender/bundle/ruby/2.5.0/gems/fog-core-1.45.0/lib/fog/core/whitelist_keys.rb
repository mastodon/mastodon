module Fog
  module WhitelistKeys
    def self.whitelist(hash, valid_keys)
      valid_hash = StringifyKeys.stringify(hash)
      Hash[valid_hash.select { |k, _v| valid_keys.include?(k) }]
    end
  end
end
