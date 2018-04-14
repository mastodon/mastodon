require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "Creating a hashed password" do

  before :each do
    @secret = "wheedle"
    @password = BCrypt::Password.create(@secret, :cost => 4)
  end

  specify "should return a BCrypt::Password" do
    expect(@password).to be_an_instance_of(BCrypt::Password)
  end

  specify "should return a valid bcrypt password" do
    expect { BCrypt::Password.new(@password) }.not_to raise_error
  end

  specify "should behave normally if the secret is not a string" do
    expect { BCrypt::Password.create(nil) }.not_to raise_error
    expect { BCrypt::Password.create({:woo => "yeah"}) }.not_to raise_error
    expect { BCrypt::Password.create(false) }.not_to raise_error
  end

  specify "should tolerate empty string secrets" do
    expect { BCrypt::Password.create( "\n".chop  ) }.not_to raise_error
    expect { BCrypt::Password.create( ""         ) }.not_to raise_error
    expect { BCrypt::Password.create( String.new ) }.not_to raise_error
  end
end

describe "Reading a hashed password" do
  before :each do
    @secret = "U*U"
    @hash = "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"
  end

  specify "the cost is too damn high" do
    expect {
      BCrypt::Password.create("hello", :cost => 32)
    }.to raise_error(ArgumentError)
  end

  specify "the cost should be set to the default if nil" do
    expect(BCrypt::Password.create("hello", :cost => nil).cost).to equal(BCrypt::Engine::DEFAULT_COST)
  end

  specify "the cost should be set to the default if empty hash" do
    expect(BCrypt::Password.create("hello", {}).cost).to equal(BCrypt::Engine::DEFAULT_COST)
  end

  specify "the cost should be set to the passed value if provided" do
    expect(BCrypt::Password.create("hello", :cost => 5).cost).to equal(5)
  end

  specify "the cost should be set to the global value if set" do
    BCrypt::Engine.cost = 5
    expect(BCrypt::Password.create("hello").cost).to equal(5)
    # unset the global value to not affect other tests
    BCrypt::Engine.cost = nil
  end

  specify "the cost should be set to an overridden constant for backwards compatibility" do
    # suppress "already initialized constant" warning
    old_verbose, $VERBOSE = $VERBOSE, nil
    old_default_cost = BCrypt::Engine::DEFAULT_COST

    BCrypt::Engine::DEFAULT_COST = 5
    expect(BCrypt::Password.create("hello").cost).to equal(5)

    # reset default to not affect other tests
    BCrypt::Engine::DEFAULT_COST = old_default_cost
    $VERBOSE = old_verbose
  end

  specify "should read the version, cost, salt, and hash" do
    password = BCrypt::Password.new(@hash)
    expect(password.version).to eql("2a")
    expect(password.version.class).to eq String
    expect(password.cost).to equal(5)
    expect(password.salt).to eql("$2a$05$CCCCCCCCCCCCCCCCCCCCC.")
    expect(password.salt.class).to eq String
    expect(password.checksum).to eq("E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW")
    expect(password.checksum.class).to eq String
    expect(password.to_s).to eql(@hash)
  end

  specify "should raise an InvalidHashError when given an invalid hash" do
    expect { BCrypt::Password.new('weedle') }.to raise_error(BCrypt::Errors::InvalidHash)
  end
end

describe "Comparing a hashed password with a secret" do
  before :each do
    @secret = "U*U"
    @hash = "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"
    @password = BCrypt::Password.create(@secret)
  end

  specify "should compare successfully to the original secret" do
    expect((@password == @secret)).to be(true)
  end

  specify "should compare unsuccessfully to anything besides original secret" do
    expect((@password == "@secret")).to be(false)
  end
end

describe "Validating a generated salt" do
  specify "should not accept an invalid salt" do
    expect(BCrypt::Engine.valid_salt?("invalid")).to eq(false)
  end
  specify "should accept a valid salt" do
    expect(BCrypt::Engine.valid_salt?(BCrypt::Engine.generate_salt)).to eq(true)
  end
end

describe "Validating a password hash" do
  specify "should not accept an invalid password" do
    expect(BCrypt::Password.valid_hash?("i_am_so_not_valid")).to be_falsey
  end
  specify "should accept a valid password" do
    expect(BCrypt::Password.valid_hash?(BCrypt::Password.create "i_am_so_valid")).to be_truthy
  end
end
