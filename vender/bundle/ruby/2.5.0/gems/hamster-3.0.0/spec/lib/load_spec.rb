# It should be possible to require any one Hamster structure,
# without loading all the others

hamster_lib_dir = File.join(File.dirname(__FILE__), "..", "..", 'lib')

describe :Hamster do
  describe :Hash do
    it "can be loaded separately" do
      system(%{ruby -e "$:.unshift('#{hamster_lib_dir}'); require 'hamster/hash'; Hamster::Hash.new"}).should be(true)
    end
  end

  describe :Set do
    it "can be loaded separately" do
      system(%{ruby -e "$:.unshift('#{hamster_lib_dir}'); require 'hamster/set'; Hamster::Set.new"}).should be(true)
    end
  end

  describe :Vector do
    it "can be loaded separately" do
      system(%{ruby -e "$:.unshift('#{hamster_lib_dir}'); require 'hamster/vector'; Hamster::Vector.new"}).should be(true)
    end
  end

  describe :List do
    it "can be loaded separately" do
      system(%{ruby -e "$:.unshift('#{hamster_lib_dir}'); require 'hamster/list'; Hamster::List[]"}).should be(true)
    end
  end

  describe :SortedSet do
    it "can be loaded separately" do
      system(%{ruby -e "$:.unshift('#{hamster_lib_dir}'); require 'hamster/sorted_set'; Hamster::SortedSet.new"}).should be(true)
    end
  end

  describe :Deque do
    it "can be loaded separately" do
      system(%{ruby -e "$:.unshift('#{hamster_lib_dir}'); require 'hamster/deque'; Hamster::Deque.new"}).should be(true)
    end
  end
end