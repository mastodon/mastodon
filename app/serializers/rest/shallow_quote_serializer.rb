# frozen_string_literal: true

class REST::ShallowQuoteSerializer < REST::BaseQuoteSerializer
  attribute :quoted_status_id

  def quoted_status_id
    quoted_status&.id&.to_s
  end
end
