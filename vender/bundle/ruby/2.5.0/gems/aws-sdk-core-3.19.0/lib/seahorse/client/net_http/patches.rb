require 'net/http'

module Seahorse
  module Client
    # @api private
    module NetHttp

      # @api private
      module Patches

        def self.apply!
          if RUBY_VERSION >= '2.0'
            Net::HTTP.send(:include, Ruby_2)
            Net::HTTP::IDEMPOTENT_METHODS_.clear
          elsif RUBY_VERSION >= '1.9.3'
            Net::HTTP.send(:include, Ruby_1_9_3)
          end
          Net::HTTP.send(:alias_method, :old_transport_request, :transport_request)
          Net::HTTP.send(:alias_method, :transport_request, :new_transport_request)
        end

        module Ruby_2
          def new_transport_request(req)
            count = 0
            begin
              begin_transport req
              res = catch(:response) {
                req.exec @socket, @curr_http_version, edit_path(req.path)
                begin
                  res = Net::HTTPResponse.read_new(@socket)
                  res.decode_content = req.decode_content
                end while res.kind_of?(Net::HTTPContinue)

                res.uri = req.uri

                res
              }
              res.reading_body(@socket, req.response_body_permitted?) {
                yield res if block_given?
              }
            rescue Net::OpenTimeout
              raise
            rescue Net::ReadTimeout, IOError, EOFError,
                   Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE,
                   # avoid a dependency on OpenSSL
                   defined?(OpenSSL::SSL) ? OpenSSL::SSL::SSLError : IOError,
                   Timeout::Error => exception
              if count == 0 && Net::HTTP::IDEMPOTENT_METHODS_.include?(req.method)
                count += 1
                @socket.close if @socket and not @socket.closed?
                D "Conn close because of error #{exception}, and retry"
                if req.body_stream
                  if req.body_stream.respond_to?(:rewind)
                    req.body_stream.rewind
                  else
                    raise
                  end
                end
                retry
              end
              D "Conn close because of error #{exception}"
              @socket.close if @socket and not @socket.closed?
              raise
            end

            end_transport req, res
            res
          rescue => exception
            D "Conn close because of error #{exception}"
            @socket.close if @socket and not @socket.closed?
            raise exception
          end
        end

        module Ruby_1_9_3
          def new_transport_request(req)
            begin_transport req
            res = catch(:response) {
              req.exec @socket, @curr_http_version, edit_path(req.path)
              begin
                res = Net::HTTPResponse.read_new(@socket)
              end while res.kind_of?(Net::HTTPContinue)
              res
            }
            res.reading_body(@socket, req.response_body_permitted?) {
              yield res if block_given?
            }
            end_transport req, res
            res
          rescue => exception
            D "Conn close because of error #{exception}"
            @socket.close if @socket and not @socket.closed?
            raise exception
          end
        end
      end
    end
  end
end
