#!/usr/bin/env ruby

require 'pg' unless defined?( PG )


class PG::Result

	# Apply a type map for all value retrieving methods.
	#
	# +type_map+: a PG::TypeMap instance.
	#
	# See PG::BasicTypeMapForResults
	def map_types!(type_map)
		self.type_map = type_map
		return self
	end


	### Return a String representation of the object suitable for debugging.
	def inspect
		str = self.to_s
		str[-1,0] = if cleared?
			" cleared"
		else
			" status=#{res_status(result_status)} ntuples=#{ntuples} nfields=#{nfields} cmd_tuples=#{cmd_tuples}"
		end
		return str
	end

end # class PG::Result

