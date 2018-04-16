require 'minitest/autorun'
require 'rack/media_type'

describe Rack::MediaType do
  before { @empty_hash = {} }

  describe 'when content_type nil' do
    before { @content_type = nil }

    it '#type is nil' do
      Rack::MediaType.type(@content_type).must_be_nil
    end

    it '#params is empty' do
      Rack::MediaType.params(@content_type).must_equal @empty_hash
    end
  end

  describe 'when content_type contains only media_type' do
    before { @content_type = 'application/text' }

    it '#type is application/text' do
      Rack::MediaType.type(@content_type).must_equal 'application/text'
    end

    it  '#params is empty' do
      Rack::MediaType.params(@content_type).must_equal @empty_hash
    end
  end

  describe 'when content_type contains media_type and params' do
    before { @content_type = 'application/text;CHARSET="utf-8"' }

    it '#type is application/text' do
      Rack::MediaType.type(@content_type).must_equal 'application/text'
    end

    it '#params has key "charset" with value "utf-8"' do
      Rack::MediaType.params(@content_type)['charset'].must_equal 'utf-8'
    end
  end
end
