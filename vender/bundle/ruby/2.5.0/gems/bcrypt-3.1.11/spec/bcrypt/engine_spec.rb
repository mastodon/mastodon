require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "The BCrypt engine" do
  specify "should calculate the optimal cost factor to fit in a specific time" do
    first = BCrypt::Engine.calibrate(100)
    second = BCrypt::Engine.calibrate(400)
    expect(second).to be > first
  end
end

describe "Generating BCrypt salts" do

  specify "should produce strings" do
    expect(BCrypt::Engine.generate_salt).to be_an_instance_of(String)
  end

  specify "should produce random data" do
    expect(BCrypt::Engine.generate_salt).to_not equal(BCrypt::Engine.generate_salt)
  end

  specify "should raise a InvalidCostError if the cost parameter isn't numeric" do
    expect { BCrypt::Engine.generate_salt('woo') }.to raise_error(BCrypt::Errors::InvalidCost)
  end

  specify "should raise a InvalidCostError if the cost parameter isn't greater than 0" do
    expect { BCrypt::Engine.generate_salt(-1) }.to raise_error(BCrypt::Errors::InvalidCost)
  end
end

describe "Autodetecting of salt cost" do

  specify "should work" do
    expect(BCrypt::Engine.autodetect_cost("$2a$08$hRx2IVeHNsTSYYtUWn61Ou")).to eq 8
    expect(BCrypt::Engine.autodetect_cost("$2a$05$XKd1bMnLgUnc87qvbAaCUu")).to eq 5
    expect(BCrypt::Engine.autodetect_cost("$2a$13$Lni.CZ6z5A7344POTFBBV.")).to eq 13
  end

end

describe "Generating BCrypt hashes" do

  class MyInvalidSecret
    undef to_s
  end

  before :each do
    @salt = BCrypt::Engine.generate_salt(4)
    @password = "woo"
  end

  specify "should produce a string" do
    expect(BCrypt::Engine.hash_secret(@password, @salt)).to be_an_instance_of(String)
  end

  specify "should raise an InvalidSalt error if the salt is invalid" do
    expect { BCrypt::Engine.hash_secret(@password, 'nino') }.to raise_error(BCrypt::Errors::InvalidSalt)
  end

  specify "should raise an InvalidSecret error if the secret is invalid" do
    expect { BCrypt::Engine.hash_secret(MyInvalidSecret.new, @salt) }.to raise_error(BCrypt::Errors::InvalidSecret)
    expect { BCrypt::Engine.hash_secret(nil, @salt) }.not_to raise_error
    expect { BCrypt::Engine.hash_secret(false, @salt) }.not_to raise_error
  end

  specify "should call #to_s on the secret and use the return value as the actual secret data" do
    expect(BCrypt::Engine.hash_secret(false, @salt)).to eq BCrypt::Engine.hash_secret("false", @salt)
  end

  specify "should be interoperable with other implementations" do
    # test vectors from the OpenWall implementation <http://www.openwall.com/crypt/>
    test_vectors = [
      ["U*U", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"],
      ["U*U*", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.VGOzA784oUp/Z0DY336zx7pLYAy0lwK"],
      ["U*U*U", "$2a$05$XXXXXXXXXXXXXXXXXXXXXO", "$2a$05$XXXXXXXXXXXXXXXXXXXXXOAcXxm9kjPGEMsLznoKqmqw7tc8WCx4a"],
      ["", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.7uG0VCzI2bS7j6ymqJi9CdcdxiRTWNy"],
      ["0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", "$2a$05$abcdefghijklmnopqrstuu", "$2a$05$abcdefghijklmnopqrstuu5s2v8.iXieOjg/.AySBTTZIIVFJeBui"]
    ]
    for secret, salt, test_vector in test_vectors
      expect(BCrypt::Engine.hash_secret(secret, salt)).to eql(test_vector)
    end
  end
end
