module PrivateAddressCheck
  PrivateConnectionAttemptedError = Class.new(StandardError)

  module_function

  def only_public_connections
    Thread.current[:private_address_check] = true
    yield
  ensure
    Thread.current[:private_address_check] = false
  end
end

TCPSocket.class_eval do
  alias initialize_without_private_address_check initialize

  def initialize(remote_host, remote_port, local_host = nil, local_port = nil)
    if Thread.current[:private_address_check] && PrivateAddressCheck.resolves_to_private_address?(remote_host)
      raise PrivateAddressCheck::PrivateConnectionAttemptedError
    end

    initialize_without_private_address_check(remote_host, remote_port, local_host, local_port)
  end
end
