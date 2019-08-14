# frozen_string_literal: true

class Api::V2::BlocksController < Api::V1::BlocksController
  def index
    @blocks = load_blocks
    render json: @blocks, each_serializer: REST::BlockSerializer
  end

  def load_blocks
    paginated_blocks.to_a
  end
end
