module BCrypt
  # A password management class which allows you to safely store users' passwords and compare them.
  #
  # Example usage:
  #
  #   include BCrypt
  #
  #   # hash a user's password
  #   @password = Password.create("my grand secret")
  #   @password #=> "$2a$10$GtKs1Kbsig8ULHZzO1h2TetZfhO4Fmlxphp8bVKnUlZCBYYClPohG"
  #
  #   # store it safely
  #   @user.update_attribute(:password, @password)
  #
  #   # read it back
  #   @user.reload!
  #   @db_password = Password.new(@user.password)
  #
  #   # compare it after retrieval
  #   @db_password == "my grand secret" #=> true
  #   @db_password == "a paltry guess"  #=> false
  #
  class Password < String
    # The hash portion of the stored password hash.
    attr_reader :checksum
    # The salt of the store password hash (including version and cost).
    attr_reader :salt
    # The version of the bcrypt() algorithm used to create the hash.
    attr_reader :version
    # The cost factor used to create the hash.
    attr_reader :cost

    class << self
      # Hashes a secret, returning a BCrypt::Password instance. Takes an optional <tt>:cost</tt> option, which is a
      # logarithmic variable which determines how computational expensive the hash is to calculate (a <tt>:cost</tt> of
      # 4 is twice as much work as a <tt>:cost</tt> of 3). The higher the <tt>:cost</tt> the harder it becomes for
      # attackers to try to guess passwords (even if a copy of your database is stolen), but the slower it is to check
      # users' passwords.
      #
      # Example:
      #
      #   @password = BCrypt::Password.create("my secret", :cost => 13)
      def create(secret, options = {})
        cost = options[:cost] || BCrypt::Engine.cost
        raise ArgumentError if cost > 31
        Password.new(BCrypt::Engine.hash_secret(secret, BCrypt::Engine.generate_salt(cost)))
      end

      def valid_hash?(h)
        h =~ /^\$[0-9a-z]{2}\$[0-9]{2}\$[A-Za-z0-9\.\/]{53}$/
      end
    end

    # Initializes a BCrypt::Password instance with the data from a stored hash.
    def initialize(raw_hash)
      if valid_hash?(raw_hash)
        self.replace(raw_hash)
        @version, @cost, @salt, @checksum = split_hash(self)
      else
        raise Errors::InvalidHash.new("invalid hash")
      end
    end

    # Compares a potential secret against the hash. Returns true if the secret is the original secret, false otherwise.
    def ==(secret)
      super(BCrypt::Engine.hash_secret(secret, @salt))
    end
    alias_method :is_password?, :==

  private

    # Returns true if +h+ is a valid hash.
    def valid_hash?(h)
      self.class.valid_hash?(h)
    end

    # call-seq:
    #   split_hash(raw_hash) -> version, cost, salt, hash
    #
    # Splits +h+ into version, cost, salt, and hash and returns them in that order.
    def split_hash(h)
      _, v, c, mash = h.split('$')
      return v.to_str, c.to_i, h[0, 29].to_str, mash[-31, 31].to_str
    end
  end

end
