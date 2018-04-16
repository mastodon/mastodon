require "spec_helper"
require "hamster/immutable"

describe Hamster::Immutable do
  class NewPerson < Struct.new(:first, :last)
    include Hamster::Immutable
  end

  let(:immutable) { NewPerson.new("Simon", "Harris") }

  it "freezes the instance" do
    expect(immutable).to be_frozen
  end

  context "subclass hides all public methods" do
    it "freezes the instance" do
      my_class = Class.new do
        include Hamster::Immutable

        (public_instance_methods - Object.public_instance_methods).each do |m|
          protected m
        end
      end
      immutable = my_class.new
      expect(immutable).to be_frozen
    end
  end
end
