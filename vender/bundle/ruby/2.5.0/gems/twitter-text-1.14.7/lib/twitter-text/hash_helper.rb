module Twitter
  module HashHelper
    # Return a new hash with all keys converted to symbols, as long as
    # they respond to +to_sym+.
    #
    #   { 'name' => 'Rob', 'years' => '28' }.symbolize_keys
    #   #=> { :name => "Rob", :years => "28" }
    def self.symbolize_keys(hash)
      symbolize_keys!(hash.dup)
    end

    # Destructively convert all keys to symbols, as long as they respond
    # to +to_sym+. Same as +symbolize_keys+, but modifies +self+.
    def self.symbolize_keys!(hash)
      hash.keys.each do |key|
        hash[(key.to_sym rescue key) || key] = hash.delete(key)
      end
      hash
    end
  end
end
