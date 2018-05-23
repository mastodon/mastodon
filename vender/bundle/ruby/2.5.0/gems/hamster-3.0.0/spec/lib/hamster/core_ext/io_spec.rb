require "spec_helper"
require "hamster/core_ext/io"

describe IO do
  describe "#to_list" do
    let(:list) { L["A\n", "B\n", "C\n"] }
    let(:to_list) { io.to_list }

    after(:each) do
      io.close
    end

    context "with a File" do
      let(:io) { File.new(fixture_path("io_spec.txt")) }

      it "returns an equivalent list" do
        expect(to_list).to eq(list)
      end
    end

    context "with a StringIO" do
      let(:io) { StringIO.new(fixture("io_spec.txt")) }

      it "returns an equivalent list" do
        expect(to_list).to eq(list)
      end
    end
  end
end
