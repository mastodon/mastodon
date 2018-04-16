# encoding: utf-8
require 'spec_helper'

describe Paperclip::FilenameCleaner do
  it 'converts invalid characters to underscores' do
    cleaner = Paperclip::FilenameCleaner.new(/[aeiou]/)
    expect(cleaner.call("baseball")).to eq "b_s_b_ll"
  end

  it 'does not convert anything if the character regex is nil' do
    cleaner = Paperclip::FilenameCleaner.new(nil)
    expect(cleaner.call("baseball")).to eq "baseball"
  end
end
