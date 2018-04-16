require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "Errors" do

  shared_examples "descends from StandardError" do
    it "can be rescued as a StandardError" do
      expect(described_class).to be < StandardError
    end
  end

  shared_examples "descends from BCrypt::Error" do
    it "can be rescued as a BCrypt::Error" do
      expect(described_class).to be < BCrypt::Error
    end
  end

  describe BCrypt::Error do
    include_examples "descends from StandardError"
  end

  describe BCrypt::Errors::InvalidCost do
    include_examples "descends from BCrypt::Error"
  end

  describe BCrypt::Errors::InvalidHash do
    include_examples "descends from BCrypt::Error"
  end

  describe BCrypt::Errors::InvalidSalt do
    include_examples "descends from BCrypt::Error"
  end

  describe BCrypt::Errors::InvalidSecret do
    include_examples "descends from BCrypt::Error"
  end

end
