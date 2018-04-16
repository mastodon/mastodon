require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'websocket/driver'
require 'permessage_deflate'

module Connection
  def initialize
    @driver = WebSocket::Driver.server(self)
    @driver.add_extension(PermessageDeflate)

    @driver.on(:connect) { |e| @driver.start if WebSocket::Driver.websocket? @driver.env }
    @driver.on(:message) { |e| @driver.frame(e.data) }
    @driver.on(:close)   { |e| close_connection_after_writing }
  end

  def receive_data(data)
    @driver.parse(data)
  end

  def write(data)
    send_data(data)
  end
end

EM.run {
  EM.start_server('127.0.0.1', ARGV[0], Connection)
}
