module Net::LDAP::Instrumentation
  attr_reader :instrumentation_service
  private     :instrumentation_service

  # Internal: Instrument a block with the defined instrumentation service.
  #
  # Yields the event payload if a block is given.
  #
  # Skips instrumentation if no service is set.
  #
  # Returns the return value of the block.
  def instrument(event, payload = {})
    payload = (payload || {}).dup
    if instrumentation_service
      instrumentation_service.instrument(event, payload) do |payload|
        payload[:result] = yield(payload) if block_given?
      end
    else
      yield(payload) if block_given?
    end
  end
  private :instrument
end
