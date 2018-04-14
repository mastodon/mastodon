# frozen_string_literal: true
module Excon
  class Response

    attr_accessor :data

    # backwards compatability reader/writers
    def body=(new_body)
      @data[:body] = new_body
    end
    def body
      @data[:body]
    end
    def headers=(new_headers)
      @data[:headers] = new_headers
    end
    def headers
      @data[:headers]
    end
    def host
      @data[:host]
    end
    def local_address
      @data[:local_address]
    end
    def local_port
      @data[:local_port]
    end
    def path
      @data[:path]
    end
    def port
      @data[:port]
    end
    def reason_phrase=(new_reason_phrase)
      @data[:reason_phrase] = new_reason_phrase
    end
    def reason_phrase
      @data[:reason_phrase]
    end
    def remote_ip=(new_remote_ip)
      @data[:remote_ip] = new_remote_ip
    end
    def remote_ip
      @data[:remote_ip]
    end
    def status=(new_status)
      @data[:status] = new_status
    end
    def status
      @data[:status]
    end
    def status_line
      @data[:status_line]
    end
    def status_line=(new_status_line)
      @data[:status_line] = new_status_line
    end

    def self.parse(socket, datum)
      # this will discard any trailing lines from the previous response if any.
      begin
        line = socket.readline
      end until status = line[9, 3].to_i

      reason_phrase = line[13..-3] # -3 strips the trailing "\r\n"

      datum[:response] = {
        :body          => String.new,
        :cookies       => [],
        :host          => datum[:host],
        :headers       => Excon::Headers.new,
        :path          => datum[:path],
        :port          => datum[:port],
        :status        => status,
        :status_line   => line,
        :reason_phrase => reason_phrase
      }

      unix_proxy = datum[:proxy] ? datum[:proxy][:scheme] == UNIX : false
      unless datum[:scheme] == UNIX || unix_proxy
        datum[:response].merge!(
          :remote_ip     => socket.remote_ip,
          :local_port    => socket.local_port,
          :local_address => socket.local_address
        )
      end

      parse_headers(socket, datum)

      unless (['HEAD', 'CONNECT'].include?(datum[:method].to_s.upcase)) || NO_ENTITY.include?(datum[:response][:status])

        if key = datum[:response][:headers].keys.detect {|k| k.casecmp('Transfer-Encoding') == 0 }
          encodings = Utils.split_header_value(datum[:response][:headers][key])
          if (encoding = encodings.last) && encoding.casecmp('chunked') == 0
            transfer_encoding_chunked = true
            if encodings.length == 1
              datum[:response][:headers].delete(key)
            else
              datum[:response][:headers][key] = encodings[0...-1].join(', ')
            end
          end
        end

        # use :response_block unless :expects would fail
        if response_block = datum[:response_block]
          if datum[:middlewares].include?(Excon::Middleware::Expects) && datum[:expects] &&
                                !Array(datum[:expects]).include?(datum[:response][:status])
            response_block = nil
          end
        end

        if transfer_encoding_chunked
          if response_block
            while (chunk_size = socket.readline.chomp!.to_i(16)) > 0
              while chunk_size > 0
                chunk = socket.read(chunk_size) || raise(EOFError)
                chunk_size -= chunk.bytesize
                response_block.call(chunk, nil, nil)
              end
              new_line_size = 2 # 2 == "\r\n".length
              while new_line_size > 0
                chunk = socket.read(new_line_size) || raise(EOFError)
                new_line_size -= chunk.length
              end
            end
          else
            while (chunk_size = socket.readline.chomp!.to_i(16)) > 0
              while chunk_size > 0
                chunk = socket.read(chunk_size) || raise(EOFError)
                chunk_size -= chunk.bytesize
                datum[:response][:body] << chunk
              end
              new_line_size = 2 # 2 == "\r\n".length
              while new_line_size > 0
                chunk = socket.read(new_line_size) || raise(EOFError)
                new_line_size -= chunk.length
              end
            end
          end
          parse_headers(socket, datum) # merge trailers into headers
        else
          if key = datum[:response][:headers].keys.detect {|k| k.casecmp('Content-Length') == 0 }
            content_length = datum[:response][:headers][key].to_i
          end

          if remaining = content_length
            if response_block
              while remaining > 0
                chunk = socket.read([datum[:chunk_size], remaining].min) || raise(EOFError)
                response_block.call(chunk, [remaining - chunk.bytesize, 0].max, content_length)
                remaining -= chunk.bytesize
              end
            else
              while remaining > 0
                chunk = socket.read([datum[:chunk_size], remaining].min) || raise(EOFError)
                datum[:response][:body] << chunk
                remaining -= chunk.bytesize
              end
            end
          else
            if response_block
              while chunk = socket.read(datum[:chunk_size])
                response_block.call(chunk, nil, nil)
              end
            else
              while chunk = socket.read(datum[:chunk_size])
                datum[:response][:body] << chunk
              end
            end
          end
        end
      end
      datum
    end

    def self.parse_headers(socket, datum)
      last_key = nil
      until (data = socket.readline.chomp).empty?
        if !data.lstrip!.nil?
          raise Excon::Error::ResponseParse, 'malformed header' unless last_key
          # append to last_key's last value
          datum[:response][:headers][last_key] << ' ' << data.rstrip
        else
          key, value = data.split(':', 2)
          raise Excon::Error::ResponseParse, 'malformed header' unless value
          # add key/value or append value to existing values
          datum[:response][:headers][key] = ([datum[:response][:headers][key]] << value.strip).compact.join(', ')
          if key.casecmp('Set-Cookie') == 0
            datum[:response][:cookies] << value.strip
          end
          last_key = key
        end
      end
    end

    def initialize(params={})
      @data = {
        :body     => ''
      }.merge(params)
      @data[:headers] = Excon::Headers.new.merge!(params[:headers] || {})

      @body          = @data[:body]
      @headers       = @data[:headers]
      @status        = @data[:status]
      @remote_ip     = @data[:remote_ip]
      @local_port    = @data[:local_port]
      @local_address = @data[:local_address]
    end

    def [](key)
      @data[key]
    end

    def params
      Excon.display_warning('Excon::Response#params is deprecated use Excon::Response#data instead.')
      data
    end

    def pp
      Excon::PrettyPrinter.pp($stdout, @data)
    end

    # Retrieve a specific header value. Header names are treated case-insensitively.
    #   @param [String] name Header name
    def get_header(name)
      headers[name]
    end

  end # class Response
end # module Excon
