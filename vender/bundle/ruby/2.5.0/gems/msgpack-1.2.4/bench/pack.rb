require 'viiite'
require 'msgpack'

data = { 'hello' => 'world', 'nested' => ['structure', {value: 42}] }
data_sym = { hello: 'world', nested: ['structure', {value: 42}] }

data = MessagePack.pack(:hello => 'world', :nested => ['structure', {:value => 42}])

Viiite.bench do |b|
  b.range_over([10_000, 100_000, 1000_000], :runs) do |runs|
    b.report(:strings) do
      runs.times do
        MessagePack.pack(data)
      end
    end

    b.report(:symbols) do
      runs.times do
        MessagePack.pack(data_sym)
      end
    end
  end
end
