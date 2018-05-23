require 'spec_helper'

describe Paperclip::GeometryParser do
  it 'identifies an image and extract its dimensions with no orientation' do
    Paperclip::Geometry.stubs(:new).with(
      height: '73',
      width: '434',
      modifier: nil,
      orientation: nil
    ).returns(:correct)
    factory = Paperclip::GeometryParser.new("434x73")

    output = factory.make

    assert_equal :correct, output
  end

  it 'identifies an image and extract its dimensions with an empty orientation' do
    Paperclip::Geometry.stubs(:new).with(
      height: '73',
      width: '434',
      modifier: nil,
      orientation: ''
    ).returns(:correct)
    factory = Paperclip::GeometryParser.new("434x73,")

    output = factory.make

    assert_equal :correct, output
  end

  it 'identifies an image and extract its dimensions and orientation' do
    Paperclip::Geometry.stubs(:new).with(
      height: '200',
      width: '300',
      modifier: nil,
      orientation: '6'
    ).returns(:correct)
    factory = Paperclip::GeometryParser.new("300x200,6")

    output = factory.make

    assert_equal :correct, output
  end

  it 'identifies an image and extract its dimensions and modifier' do
    Paperclip::Geometry.stubs(:new).with(
      height: '64',
      width: '64',
      modifier: '#',
      orientation: nil
    ).returns(:correct)
    factory = Paperclip::GeometryParser.new("64x64#")

    output = factory.make

    assert_equal :correct, output
  end

  it 'identifies an image and extract its dimensions, orientation, and modifier' do
    Paperclip::Geometry.stubs(:new).with(
      height: '50',
      width: '100',
      modifier: '>',
      orientation: '7'
    ).returns(:correct)
    factory = Paperclip::GeometryParser.new("100x50,7>")

    output = factory.make

    assert_equal :correct, output
  end
end
