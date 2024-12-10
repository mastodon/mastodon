# frozen_string_literal: true

# Ensure TimeWithZone are represented as RFC3339 DateTime with 3 digits of
# precision for the fractional part of the second.
#
# This matches the external API commitment documented at
# https://docs.joinmastodon.org/api/datetime-format/#datetime.
class ActiveSupport::TimeWithZone
  def as_json(_options = {})
    rfc3339(3)
  end
end
