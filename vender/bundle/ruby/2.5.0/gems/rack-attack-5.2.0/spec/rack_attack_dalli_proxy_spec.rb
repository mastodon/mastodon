require_relative 'spec_helper'

describe Rack::Attack::StoreProxy::DalliProxy do

  it 'should stub Dalli::Client#with on older clients' do
    proxy = Rack::Attack::StoreProxy::DalliProxy.new(Class.new)
    proxy.with {} # will not raise an error
  end

end
