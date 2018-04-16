# -*- encoding: utf-8 -*-
require 'minitest/autorun'
require 'rack'

describe Rack do
  describe 'version' do
    it 'defaults to a hard-coded api version' do
      Rack.version.must_equal "1.3"
    end
  end
end
