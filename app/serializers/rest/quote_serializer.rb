# frozen_string_literal: true

class REST::QuoteSerializer < REST::BaseQuoteSerializer
  has_one :quoted_status, serializer: REST::ShallowStatusSerializer
end
