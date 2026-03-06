# frozen_string_literal: true

# Ensure Time and ActiveSupport::TimeWithZone always serialize to ISO 8601 when
# used inside structures passed to JSON.generate / JSON.dump.
#
# Background: ActiveSupport's Time#to_json produces ISO 8601 when called with no
# arguments, but when the stdlib `json` gem calls it during serialization of a
# containing Hash/Array it passes a JSON::State argument.  ActiveSupport detects
# that argument and falls back to `to_s.to_json`, producing a different format
# ("2024-01-15 12:00:00 UTC" instead of "2024-01-15T12:00:00.000Z").
#
# Previously, the `oj` gem (in compat mode) called `to_json` without a State
# object, so the ISO 8601 path was always taken.  This initializer preserves
# that behavior now that we use the stdlib `json` gem directly.
#
# See: https://github.com/mastodon/mastodon/pull/32704
#      https://github.com/mastodon/mastodon/pull/37752

[Time, ActiveSupport::TimeWithZone].each do |klass|
  klass.define_method(:to_json) do |*_args|
    iso8601(3).to_json
  end
end
