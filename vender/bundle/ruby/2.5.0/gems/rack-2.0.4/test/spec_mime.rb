require 'minitest/autorun'
require 'rack/mime'

describe Rack::Mime do

  it "should return the fallback mime-type for files with no extension" do
    fallback = 'image/jpg'
    Rack::Mime.mime_type(File.extname('no_ext'), fallback).must_equal fallback
  end

  it "should always return 'application/octet-stream' for unknown file extensions" do
    unknown_ext = File.extname('unknown_ext.abcdefg')
    Rack::Mime.mime_type(unknown_ext).must_equal 'application/octet-stream'
  end

  it "should return the mime-type for a given extension" do
    # sanity check. it would be infeasible test every single mime-type.
    Rack::Mime.mime_type(File.extname('image.jpg')).must_equal 'image/jpeg'
  end

  it "should support null fallbacks" do
    Rack::Mime.mime_type('.nothing', nil).must_be_nil
  end

  it "should match exact mimes" do
    Rack::Mime.match?('text/html', 'text/html').must_equal true
    Rack::Mime.match?('text/html', 'text/meme').must_equal false
    Rack::Mime.match?('text', 'text').must_equal true
    Rack::Mime.match?('text', 'binary').must_equal false
  end

  it "should match class wildcard mimes" do
    Rack::Mime.match?('text/html', 'text/*').must_equal true
    Rack::Mime.match?('text/plain', 'text/*').must_equal true
    Rack::Mime.match?('application/json', 'text/*').must_equal false
    Rack::Mime.match?('text/html', 'text').must_equal true
  end

  it "should match full wildcards" do
    Rack::Mime.match?('text/html', '*').must_equal true
    Rack::Mime.match?('text/plain', '*').must_equal true
    Rack::Mime.match?('text/html', '*/*').must_equal true
    Rack::Mime.match?('text/plain', '*/*').must_equal true
  end

  it "should match type wildcard mimes" do
    Rack::Mime.match?('text/html', '*/html').must_equal true
    Rack::Mime.match?('text/plain', '*/plain').must_equal true
  end

end
