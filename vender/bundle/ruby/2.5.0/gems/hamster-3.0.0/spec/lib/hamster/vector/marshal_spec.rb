require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#marshal_dump/#marshal_load" do
    let(:ruby) do
      File.join(RbConfig::CONFIG["bindir"], RbConfig::CONFIG["ruby_install_name"])
    end
    let(:child_cmd) do
      %Q|#{ruby} -I lib -r hamster -e 'vector = Hamster::Vector[5, 10, 15]; $stdout.write(Marshal.dump(vector))'|
    end

    let(:reloaded_vector) do
      IO.popen(child_cmd, "r+") do |child|
        reloaded_vector = Marshal.load(child)
        child.close
        reloaded_vector
      end
    end

    it "can survive dumping and loading into a new process" do
      expect(reloaded_vector).to eql(V[5, 10, 15])
    end

    it "is still possible to find items by index after loading" do
      expect(reloaded_vector[0]).to eq(5)
      expect(reloaded_vector[1]).to eq(10)
      expect(reloaded_vector[2]).to eq(15)
      expect(reloaded_vector.size).to eq(3)
    end
  end
end