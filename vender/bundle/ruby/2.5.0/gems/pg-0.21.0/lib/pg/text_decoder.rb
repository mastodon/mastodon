#!/usr/bin/env ruby

require 'date'
require 'json'

module PG
	module TextDecoder
		class Date < SimpleDecoder
			ISO_DATE = /\A(\d{4})-(\d\d)-(\d\d)\z/

			def decode(string, tuple=nil, field=nil)
				if string =~ ISO_DATE
					::Date.new $1.to_i, $2.to_i, $3.to_i
				else
					string
				end
			end
		end

		class TimestampWithoutTimeZone < SimpleDecoder
			ISO_DATETIME_WITHOUT_TIMEZONE = /\A(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)(\.\d+)?\z/

			def decode(string, tuple=nil, field=nil)
				if string =~ ISO_DATETIME_WITHOUT_TIMEZONE
					Time.new $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, "#{$6}#{$7}".to_r
				else
					string
				end
			end
		end

		class TimestampWithTimeZone < SimpleDecoder
			ISO_DATETIME_WITH_TIMEZONE = /\A(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)(\.\d+)?([-\+]\d\d):?(\d\d)?:?(\d\d)?\z/

			def decode(string, tuple=nil, field=nil)
				if string =~ ISO_DATETIME_WITH_TIMEZONE
					Time.new $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, "#{$6}#{$7}".to_r, "#{$8}:#{$9 || '00'}:#{$10 || '00'}"
				else
					string
				end
			end
		end

		class JSON < SimpleDecoder
			def decode(string, tuple=nil, field=nil)
				::JSON.parse(string, quirks_mode: true)
			end
		end
	end
end # module PG

