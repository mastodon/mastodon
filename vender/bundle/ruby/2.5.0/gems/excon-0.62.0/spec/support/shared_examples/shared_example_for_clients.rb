require 'time'

shared_examples_for 'a basic client' do |url = 'http://127.0.0.1:9292', opts = {}|
  # TODO: Ditch iterator and manually write a context for each set of options
  ([true, false] * 2).combination(2).to_a.uniq.each do |nonblock, persistent|
    context "when nonblock is #{nonblock} and persistent is #{persistent}" do
      opts = opts.merge(ssl_verify_peer: false, nonblock: nonblock, persistent: persistent)

      let(:conn) { Excon.new(url, opts) }

      context 'when :method is get and :path is /content-length/100' do
        describe '#request' do
          let(:response) do
            conn.request(method: :get, path: '/content-length/100')
          end

          it 'returns an Excon::Response' do
            expect(response).to be_instance_of Excon::Response
          end
          describe Excon::Response do
            describe '#status' do
              it 'returns 200' do
                expect(response.status).to eq 200
              end

              it '#status returns 200' do
                expect(response[:status]).to eq 200
              end
            end
            describe '#headers' do
              it '["Content-Length"] returns 100' do
                expect(response.headers['Content-Length']).to eq '100'
              end
              it '["Content-Type"] returns  "text/html;charset=utf-8"' do
                expect(response.headers['Content-Type']).to eq 'text/html;charset=utf-8'
              end

              it "['Date'] returns a valid date" do
                if RUBY_PLATFORM == 'java' && conn.data[:scheme] == Excon::UNIX
                  skip('until puma responds with a date header')
                else
                  time = Time.parse(response.headers['Date'])
                  expect(time.is_a?(Time)).to be true
                end
              end

              it "['Server'] matches /^WEBrick/" do
                pending('until unix_socket response has server header') if conn.data[:scheme] == Excon::UNIX
                expect(!!(response.headers['Server'] =~ /^WEBrick/)).to be true
              end

              it "['Custom'] returns Foo: bar" do
                expect(response.headers['Custom']).to eq 'Foo: bar'
              end
            end
            describe '#remote_ip' do
              it 'returns 127.0.0.1' do
                pending('until pigs can fly') if conn.data[:scheme] == Excon::UNIX
                expect(response.remote_ip).to eq '127.0.0.1'
              end
            end
          end

          context('when tcp_nodelay is true') do
            describe '#request' do
              response = nil
              options = opts.merge(ssl_verify_peer: false, nonblock: nonblock, tcp_nodelay: true)
              connection = Excon.new(url, options)

              it 'returns an Excon::Response' do
                expect do
                  response = connection.request(method: :get, path: '/content-length/100')
                end.to_not raise_error
              end

              describe Excon::Response do
                describe '#body' do
                  describe '.status' do
                    it '#returns 200' do
                      expect(response.status).to eq 200
                    end
                  end
                end
              end
            end
          end
        end

        context 'when utilizing deprecated block usage' do
          describe '#request' do
            data = []
            it 'yields with a chunk, remaining length, and total length' do
              expect do
                conn.request(method: :get, path: '/content-length/100') do |chunk, remaining_length, total_length|
                  data = [chunk, remaining_length, total_length]
                end
              end.to_not raise_error
            end
            it 'completes with expected data' do
              expect(data).to eq ['x' * 100, 0, 100]
            end
          end
        end

        context 'when utilizing response_block usage' do
          describe '#request' do
            data = []
            it 'yields a chunk, remaining length, and total_length' do
              response_block = lambda do |chunk, remaining_length, total_length|
                data = [chunk, remaining_length, total_length]
              end
              expect do
                conn.request(method: :get, path: '/content-length/100', response_block: response_block)
              end.to_not raise_error
            end
            it 'completes with expected data' do
              expect(data).to eq ['x' * 100, 0, 100]
            end
          end
        end
        context 'when method is :post' do
          context 'when :path is /body-sink' do
            context 'when a body parameter is supplied' do
              response = nil
              it 'returns an Excon::Response' do
                response = conn.request(method: :post, path: '/body-sink', headers: { 'Content-Type' => 'text/plain' }, body: 'x' * 5_000_000)
                expect(response).to be_instance_of Excon::Response
              end
              describe Excon::Response do
                describe '#body' do
                  it 'equals "5000000"' do
                    expect(response.body).to eq '5000000'
                  end
                end
              end
            end
            context 'when the body parameter is an empty string' do
              response = nil

              it 'returns an Excon::Response' do
                response = conn.request(method: :post, path: '/body-sink', headers: { 'Content-Type' => 'text/plain' }, body: '')
                expect(response).to be_instance_of Excon::Response
              end
              describe Excon::Response do
                describe '#body' do
                  it 'equals "0"' do
                    expect(response.body).to eq '0'
                  end
                end
              end
            end
          end

          context 'when :path is /echo' do
            context('when a file handle is the body paramter') do
              describe Excon::Response do
                it '#body equals "x" * 100 + "\n"' do
                  file_path = data_path('xs')
                  response = conn.request(method: :post, path: '/echo', body: File.open(file_path))
                  expect(response.body).to eq 'x' * 100 + "\n"
                end
              end
            end

            context 'when a string is the body paramter' do
              it 'does not change the econding of the body' do
                skip unless RUBY_VERSION >= '1.9'

                string_body = '¥£€'
                expect do
                  conn.request(method: :post, path: '/echo', body: string_body)
                end.to_not change { string_body.encoding }
              end

              context 'without request_block' do
                describe Excon::Response do
                  it "#body equals 'x' * 100)" do
                    response = conn.request(method: :post, path: '/echo', body: 'x' * 100)
                    expect(response.body).to eq 'x' * 100
                  end
                end
              end

              context 'when a request_block paramter is supplied' do
                describe Excon::Response do
                  it "#body equals'x' * 100" do
                    data = ['x'] * 100
                    request_block = lambda do
                      data.shift.to_s
                    end
                    response = conn.request(method: :post, path: '/echo', request_block: request_block)
                    expect(response.body).to eq 'x' * 100
                  end
                end
              end

              context('when a multi-byte string is the body paramter') do
                body = "\xC3\xBC" * 100
                headers = { 'Custom' => body.dup }
                if RUBY_VERSION >= '1.9'
                  body.force_encoding('BINARY')
                  headers['Custom'].force_encoding('UTF-8')
                end
                describe Excon::Response do
                  it '#body properly concatenates request+headers and body' do
                    response = conn.request(method: :post, path: '/echo',
                                            headers: headers, body: body)
                    expect(response.body).to eq body
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
