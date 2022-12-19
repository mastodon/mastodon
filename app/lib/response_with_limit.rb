class ResponseWithLimit
  def initialize(response, limit)
    @response = response
    @limit = limit
  end

  attr_reader :response, :limit
end
