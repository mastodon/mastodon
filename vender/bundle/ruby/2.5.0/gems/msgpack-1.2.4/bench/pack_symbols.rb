require 'viiite'
require 'msgpack'

data = :symbol

Viiite.bench do |b|
  b.variation_point :branch, `git rev-parse --abbrev-ref HEAD`

  b.range_over([:symbol, :none], :reg_type) do |reg_type|
    packer = MessagePack::Packer.new
    packer.register_type(0x00, Symbol, :to_msgpack_ext) if reg_type == :symbol

    b.range_over([100_000, 1_000_000, 10_000_000], :count) do |count|
      packer.clear
      b.report(:multi_run) do
        count.times do
          packer.pack(data)
        end
      end

      packer.clear
      items_data = [].fill(data, 0, count)
      b.report(:large_run) do
        packer.pack(items_data)
      end
    end
  end
end
