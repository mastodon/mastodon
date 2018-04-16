# Copyright (c) 2011, Peter Ohler<br>
# All rights reserved.

#
# === Description:
# 
# Ox handles XML documents in two ways. It is a generic XML parser and writer as
# well as a fast Object / XML marshaller. Ox was written for speed as a
# replacement for Nokogiri and for Marshal.
# 
# As an XML parser it is 2 or more times faster than Nokogiri and as a generic
# XML writer it is 14 times faster than Nokogiri. Of course different files may
# result in slightly different times.
# 
# As an Object serializer Ox is 4 times faster than the standard Ruby
# Marshal.dump(). Ox is 3 times faster than Marshal.load().
# 
# === Object Dump Sample:
# 
#   require 'ox'
# 
#   class Sample
#     attr_accessor :a, :b, :c
# 
#     def initialize(a, b, c)
#       @a = a
#       @b = b
#       @c = c
#     end
#   end
# 
#   # Create Object
#   obj = Sample.new(1, "bee", ['x', :y, 7.0])
#   # Now dump the Object to an XML String.
#   xml = Ox.dump(obj)
#   # Convert the object back into a Sample Object.
#   obj2 = Ox.parse_obj(xml)
# 
# === Generic XML Writing and Parsing:
# 
#   require 'ox'
# 
#   doc = Ox::Document.new(:version => '1.0')
# 
#   top = Ox::Element.new('top')
#   top[:name] = 'sample'
#   doc << top
# 
#   mid = Ox::Element.new('middle')
#   mid[:name] = 'second'
#   top << mid
# 
#   bot = Ox::Element.new('bottom')
#   bot[:name] = 'third'
#   mid << bot
# 
#   xml = Ox.dump(doc)
#   puts xml
#   doc2 = Ox.parse(xml)
#   puts "Same? #{doc == doc2}"
module Ox

end

require 'ox/version'
require 'ox/error'
require 'ox/hasattrs'
require 'ox/node'
require 'ox/comment'
require 'ox/raw'
require 'ox/instruct'
require 'ox/cdata'
require 'ox/doctype'
require 'ox/element'
require 'ox/document'
require 'ox/bag'
require 'ox/sax'

require 'ox/ox' # C extension
