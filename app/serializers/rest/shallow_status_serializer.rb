# frozen_string_literal: true

class REST::ShallowStatusSerializer < REST::StatusSerializer
  has_one :quote, key: :quote, serializer: REST::ShallowQuoteSerializer

  # It looks like redefining one `has_one` requires redefining all inherited ones
  has_one :preview_card, key: :card, serializer: REST::PreviewCardSerializer
  has_one :preloadable_poll, key: :poll, serializer: REST::PollSerializer
  has_one :quote_approval
end
