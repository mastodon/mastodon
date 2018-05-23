#!/usr/bin/env ruby

require 'json'

module PG
	module TextEncoder
		class Date < SimpleEncoder
			STRFTIME_ISO_DATE = "%Y-%m-%d".freeze
			def encode(value)
				value.respond_to?(:strftime) ? value.strftime(STRFTIME_ISO_DATE) : value
			end
		end

		class TimestampWithoutTimeZone < SimpleEncoder
			STRFTIME_ISO_DATETIME_WITHOUT_TIMEZONE = "%Y-%m-%d %H:%M:%S.%N".freeze
			def encode(value)
				value.respond_to?(:strftime) ? value.strftime(STRFTIME_ISO_DATETIME_WITHOUT_TIMEZONE) : value
			end
		end

		class TimestampWithTimeZone < SimpleEncoder
			STRFTIME_ISO_DATETIME_WITH_TIMEZONE = "%Y-%m-%d %H:%M:%S.%N %:z".freeze
			def encode(value)
				value.respond_to?(:strftime) ? value.strftime(STRFTIME_ISO_DATETIME_WITH_TIMEZONE) : value
			end
		end

		class JSON < SimpleEncoder
			def encode(value)
				::JSON.generate(value, quirks_mode: true)
			end
		end
	end
end # module PG

