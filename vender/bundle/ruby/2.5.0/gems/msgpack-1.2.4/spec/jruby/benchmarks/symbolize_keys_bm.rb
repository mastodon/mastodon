# encoding: utf-8

$: << File.expand_path('../../../lib', __FILE__)

require 'viiite'
require 'msgpack'


iterations = 10_000
data = MessagePack.pack(:hello => 'world', :nested => ['structure', {:value => 42}])

Viiite.bm do |b|
  b.report(:strings) do
    iterations.times do
      MessagePack.unpack(data)
    end
  end

  b.report(:symbols) do
    options = {:symbolize_keys => true}
    iterations.times do
      MessagePack.unpack(data, options)
    end
  end
end