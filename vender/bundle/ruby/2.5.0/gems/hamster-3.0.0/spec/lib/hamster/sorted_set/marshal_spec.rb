require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#marshal_dump/#marshal_load" do
    let(:ruby) do
      File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["ruby_install_name"])
    end
    let(:child_cmd) do
      %Q|#{ruby} -I lib -r hamster -e 'set = Hamster::SortedSet[5, 10, 15]; $stdout.write(Marshal.dump(set))'|
    end

    let(:reloaded_set) do
      IO.popen(child_cmd, "r+") do |child|
        reloaded_set = Marshal.load(child)
        child.close
        reloaded_set
      end
    end

    it "can survive dumping and loading into a new process" do
      expect(reloaded_set).to eql(SS[5, 10, 15])
    end

    it "is still possible to find items by index after loading" do
      expect(reloaded_set[0]).to eq(5)
      expect(reloaded_set[1]).to eq(10)
      expect(reloaded_set[2]).to eq(15)
      expect(reloaded_set.size).to eq(3)
    end

    it "raises a TypeError if set has a custom sort order" do
      # this is because comparator block can't be serialized
      -> { Marshal.dump(SS.new([1, 2, 3]) { |x| -x }) }.should raise_error(TypeError)
    end
  end
end
