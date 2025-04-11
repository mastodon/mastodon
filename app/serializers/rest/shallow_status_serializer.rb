# frozen_string_literal: true

class REST::ShallowStatusSerializer < REST::StatusSerializer
  # It looks like defining one `has_one` requires redefining all of them
  has_one :quote, key: :quote, serializer: REST::ShallowQuoteSerializer
  has_one :preview_card, key: :card, serializer: REST::PreviewCardSerializer
  has_one :preloadable_poll, key: :poll, serializer: REST::PollSerializer
end
