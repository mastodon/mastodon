require "thread"

module Fog
  class CurrentMachine
    @lock = Mutex.new

    AMAZON_AWS_CHECK_IP = "http://checkip.amazonaws.com"

    def self.ip_address=(ip_address)
      @lock.synchronize do
        @ip_address = ip_address
      end
    end

    # Get the ip address of the machine from which this command is run. It is
    # recommended that you surround calls to this function with a timeout block
    # to ensure optimum performance in the case where the amazonaws checkip
    # service is unavailable.
    #
    # @example Get the current ip address
    #   begin
    #     Timeout::timeout(5) do
    #       puts "Your ip address is #{Fog::CurrentMachine.ip_address}"
    #     end
    #   rescue Timeout::Error
    #     puts "Service timeout"
    #   end
    #
    # @raise [Excon::Errors::Error] if the net/http request fails.
    def self.ip_address
      @lock.synchronize do
        @ip_address ||= Excon.get(AMAZON_AWS_CHECK_IP).body.chomp
      end
    end
  end
end
