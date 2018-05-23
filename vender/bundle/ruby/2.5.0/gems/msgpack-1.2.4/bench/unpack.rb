require 'viiite'
require 'msgpack'

data = MessagePack.pack(:hello => 'world', :nested => ['structure', {:value => 42}])

Viiite.bench do |b|
  b.range_over([10_000, 100_000, 1000_000], :runs) do |runs|
    b.report(:strings) do
      runs.times do
        MessagePack.unpack(data)
      end
    end

    b.report(:symbols) do
      options = {:symbolize_keys => true}
      runs.times do
        MessagePack.unpack(data, options)
      end
    end
  end
end
