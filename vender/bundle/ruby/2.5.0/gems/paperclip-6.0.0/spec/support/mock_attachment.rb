class MockAttachment
  attr_accessor :updated_at, :original_filename
  attr_reader :options

  def initialize(options = {})
    @options = options
    @model = options[:model]
    @responds_to_updated_at = options[:responds_to_updated_at]
    @updated_at = options[:updated_at]
    @original_filename = options[:original_filename]
  end

  def instance
    @model
  end

  def respond_to?(meth)
    if meth.to_s == "updated_at"
      @responds_to_updated_at || @updated_at
    else
      super
    end
  end
end
