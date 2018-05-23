#--
# Copyright (c) 2008, 2009 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'stringio'
module Hitimes
  class Stats
    # A list of the available stats
    STATS = %w[ count max mean min rate stddev sum sumsq ]

    # 
    # call-seq:
    #   stat.to_hash   -> Hash
    #   stat.to_hash( %w[ count max mean ]) -> Hash
    #
    # return a hash of the stats.  By default this returns a hash of all stats
    # but passing in an array of items will limit the stats returned to only
    # those in the Array. 
    #
    # If passed in an empty array or nil to to_hash then STATS is assumed to be
    # the list of stats to return in the hash.
    #
    def to_hash( *args )
      h = {}
      args = [ args ].flatten
      args = STATS if args.empty?
      args.each do |meth|
        h[meth] = self.send( meth )
      end
      return h
    end

    #
    # call-seq:
    #   stat.to_json  -> String
    #   stat.to_json( *args ) -> String
    #
    # return a json string of the stats.  By default this returns a json string
    # of all the stats.  If an array of items is passed in, those that match the
    # known stats will be all that is included in the json output.
    #
    def to_json( *args )
      h = to_hash( *args )
      a = []
      s = StringIO.new

      s.print "{ "
      h.each_pair do |k,v|
        a << "\"#{k}\": #{v}"
      end
      s.print a.join(", ")
      s.print "}"
      return s.string
    end

  end
end
