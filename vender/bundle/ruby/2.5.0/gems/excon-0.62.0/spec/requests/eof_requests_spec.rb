require 'spec_helper'

describe Excon do
  context "when dispatching requests" do
    context('to a server that does not supply response headers') do
      include_context("test server", :exec, 'bad.rb', :before => :start, :after => :stop )
      before(:all) do
        @conn = Excon.new('http://127.0.0.1:9292')
      end

      context('when no block is given') do
        it 'should rescue from an EOFError and return response' do
          body = @conn.request(:method => :get, :path => '/eof/no_content_length_and_no_chunking').body
        expect(body).to eq 'hello'
        end
      end

      context('when a block is given') do
        it 'should rescue from EOFError and return response' do
          body = ""
          response_block = lambda {|chunk, remaining, total| body << chunk }
          @conn.request(:method => :get, :path => '/eof/no_content_length_and_no_chunking', :response_block => response_block)
          expect(body).to eq 'hello'
        end
      end
    end

    context('to a server that prematurely aborts the request with no response') do
      include_context("test server", :exec, 'eof.rb', :before => :start, :after => :stop )

      it 'should raise an EOFError' do
        expect { Excon.get('http://127.0.0.1:9292/eof') }.to raise_error(Excon::Errors::SocketError)
      end
    end
  end
end
