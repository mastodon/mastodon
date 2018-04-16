module BCrypt
  # A Ruby wrapper for the bcrypt() C extension calls and the Java calls.
  class Engine
    # The default computational expense parameter.
    DEFAULT_COST    = 10
    # The minimum cost supported by the algorithm.
    MIN_COST        = 4
    # Maximum possible size of bcrypt() salts.
    MAX_SALT_LENGTH = 16

    if RUBY_PLATFORM != "java"
      # C-level routines which, if they don't get the right input, will crash the
      # hell out of the Ruby process.
      private_class_method :__bc_salt
      private_class_method :__bc_crypt
    end

    @cost = nil

    # Returns the cost factor that will be used if one is not specified when
    # creating a password hash.  Defaults to DEFAULT_COST if not set.
    def self.cost
      @cost || DEFAULT_COST
    end

    # Set a default cost factor that will be used if one is not specified when
    # creating a password hash.
    #
    # Example:
    #
    #   BCrypt::Engine::DEFAULT_COST            #=> 10
    #   BCrypt::Password.create('secret').cost  #=> 10
    #
    #   BCrypt::Engine.cost = 8
    #   BCrypt::Password.create('secret').cost  #=> 8
    #
    #   # cost can still be overridden as needed
    #   BCrypt::Password.create('secret', :cost => 6).cost  #=> 6
    def self.cost=(cost)
      @cost = cost
    end

    # Given a secret and a valid salt (see BCrypt::Engine.generate_salt) calculates
    # a bcrypt() password hash.
    def self.hash_secret(secret, salt, _ = nil)
      if valid_secret?(secret)
        if valid_salt?(salt)
          if RUBY_PLATFORM == "java"
            Java.bcrypt_jruby.BCrypt.hashpw(secret.to_s, salt.to_s)
          else
            __bc_crypt(secret.to_s, salt)
          end
        else
          raise Errors::InvalidSalt.new("invalid salt")
        end
      else
        raise Errors::InvalidSecret.new("invalid secret")
      end
    end

    # Generates a random salt with a given computational cost.
    def self.generate_salt(cost = self.cost)
      cost = cost.to_i
      if cost > 0
        if cost < MIN_COST
          cost = MIN_COST
        end
        if RUBY_PLATFORM == "java"
          Java.bcrypt_jruby.BCrypt.gensalt(cost)
        else
          prefix = "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"
          __bc_salt(prefix, cost, OpenSSL::Random.random_bytes(MAX_SALT_LENGTH))
        end
      else
        raise Errors::InvalidCost.new("cost must be numeric and > 0")
      end
    end

    # Returns true if +salt+ is a valid bcrypt() salt, false if not.
    def self.valid_salt?(salt)
      !!(salt =~ /^\$[0-9a-z]{2,}\$[0-9]{2,}\$[A-Za-z0-9\.\/]{22,}$/)
    end

    # Returns true if +secret+ is a valid bcrypt() secret, false if not.
    def self.valid_secret?(secret)
      secret.respond_to?(:to_s)
    end

    # Returns the cost factor which will result in computation times less than +upper_time_limit_in_ms+.
    #
    # Example:
    #
    #   BCrypt::Engine.calibrate(200)  #=> 10
    #   BCrypt::Engine.calibrate(1000) #=> 12
    #
    #   # should take less than 200ms
    #   BCrypt::Password.create("woo", :cost => 10)
    #
    #   # should take less than 1000ms
    #   BCrypt::Password.create("woo", :cost => 12)
    def self.calibrate(upper_time_limit_in_ms)
      40.times do |i|
        start_time = Time.now
        Password.create("testing testing", :cost => i+1)
        end_time = Time.now - start_time
        return i if end_time * 1_000 > upper_time_limit_in_ms
      end
    end

    # Autodetects the cost from the salt string.
    def self.autodetect_cost(salt)
      salt[4..5].to_i
    end
  end

end
