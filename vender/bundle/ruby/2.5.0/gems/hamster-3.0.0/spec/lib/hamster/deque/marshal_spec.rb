require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  describe "#marshal_dump/#marshal_load" do
    let(:ruby) do
      File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["ruby_install_name"])
    end
    let(:child_cmd) do
      %Q|#{ruby} -I lib -r hamster -e 'deque = Hamster::Deque[5, 10, 15]; $stdout.write(Marshal.dump(deque))'|
    end

    let(:reloaded_deque) do
      IO.popen(child_cmd, "r+") do |child|
        reloaded_deque = Marshal.load(child)
        child.close
        reloaded_deque
      end
    end

    it "can survive dumping and loading into a new process" do
      expect(reloaded_deque).to eql(D[5, 10, 15])
    end

    it "is still possible to push and pop items after loading" do
      expect(reloaded_deque.first).to eq(5)
      expect(reloaded_deque.last).to eq(15)
      expect(reloaded_deque.push(20)).to eql(D[5, 10, 15, 20])
      expect(reloaded_deque.pop).to eql(D[5, 10])
      expect(reloaded_deque.unshift(1)).to eql(D[1, 5, 10, 15])
      expect(reloaded_deque.shift).to eql(D[10, 15])
    end
  end
end