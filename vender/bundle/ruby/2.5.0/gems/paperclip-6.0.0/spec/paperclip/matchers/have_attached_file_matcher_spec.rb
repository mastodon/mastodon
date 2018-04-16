require 'spec_helper'
require 'paperclip/matchers'

describe Paperclip::Shoulda::Matchers::HaveAttachedFileMatcher do
  extend Paperclip::Shoulda::Matchers

  it "rejects the dummy class if it has no attachment" do
    reset_table "dummies"
    reset_class "Dummy"
    matcher = self.class.have_attached_file(:avatar)
    expect(matcher).to_not accept(Dummy)
  end

  it 'accepts the dummy class if it has an attachment' do
    rebuild_model
    matcher = self.class.have_attached_file(:avatar)
    expect(matcher).to accept(Dummy)
  end
end
