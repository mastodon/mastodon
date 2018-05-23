require 'spec_helper'

describe Paperclip::IdentityAdapter do
  it "responds to #new by returning the argument" do
    adapter = Paperclip::IdentityAdapter.new
    assert_equal :target, adapter.new(:target, nil)
  end
end
