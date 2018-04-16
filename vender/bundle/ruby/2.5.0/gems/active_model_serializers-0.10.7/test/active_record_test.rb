require 'test_helper'

class ActiveRecordTest < ActiveSupport::TestCase
  include ActiveModel::Serializer::Lint::Tests

  def setup
    @resource = ARModels::Post.new
  end
end
