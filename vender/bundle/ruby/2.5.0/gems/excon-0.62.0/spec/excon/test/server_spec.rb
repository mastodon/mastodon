require 'spec_helper'

describe Excon::Test::Server do
  
  context 'when the web server is webrick' do
    it_should_behave_like "a excon test server", :webrick, 'basic.ru'
  end


  context 'when the web server is unicorn' do 
    context 'bound to a tcp socket' do
      it_should_behave_like "a excon test server", :unicorn, 'streaming.ru'
    end

    context "bound to a unix socket" do
      socket_uri = 'unix:///tmp/unicorn.socket'
      it_should_behave_like "a excon test server", :unicorn, 'streaming.ru', socket_uri
    end
  end

  context 'when the web server is puma' do
    it_should_behave_like "a excon test server", :puma, 'streaming.ru'
  end

  context 'when the web server is a executable' do
    it_should_behave_like "a excon test server", :exec, 'good.rb'
  end
end
