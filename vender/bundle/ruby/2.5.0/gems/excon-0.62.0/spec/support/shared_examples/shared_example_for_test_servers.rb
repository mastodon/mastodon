shared_examples_for "a excon test server" do |plugin, file|

    include_context("test server", plugin, file)

    it "returns an instance" do
      expect(@server).to be_instance_of Excon::Test::Server
    end

    it 'starts the server' do
      expect(@server.start).to be true
    end

    it 'stops the server' do
      expect(@server.stop).to be true
    end
end
