require 'test_helper'

class PoroTest < ActiveSupport::TestCase
  include ActiveModel::Serializer::Lint::Tests

  def setup
    @resource = Model.new
  end
end
