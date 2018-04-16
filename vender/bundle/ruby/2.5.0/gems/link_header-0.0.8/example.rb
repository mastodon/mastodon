require "link_header"
require "pp"

#
# Create a LinkHeader with Link objects
#
link_header = LinkHeader.new([
  LinkHeader::Link.new("http://example.com/foo", [["rel", "self"]]),
  LinkHeader::Link.new("http://example.com/",    [["rel", "up"]])])

puts link_header.to_s
#=> <http://example.com/foo>; rel="self", <http://example.com/>; rel="up"

link_header.links.map do |link|
  puts "href #{link.href.inspect}, attr_pairs #{link.attr_pairs.inspect}, attrs #{link.attrs.inspect}"
end
#=> href "http://example.com/foo", attr_pairs [["rel", "self"]], attrs {"rel"=>"self"}
#   href "http://example.com/", attr_pairs [["rel", "up"]], attrs {"rel"=>"up"}

#
# Create a LinkHeader from raw (JSON-friendly) data
#
puts LinkHeader.new([
  ["http://example.com/foo", [["rel", "self"]]],
  ["http://example.com/",    [["rel", "up"]]]]).to_s
#=> <http://example.com/foo>; rel="self", <http://example.com/>; rel="up"

#
# Parse a link header into a LinkHeader object then produce its raw data representation
#
pp LinkHeader.parse('<http://example.com/foo>; rel="self", <http://example.com/>; rel = "up"').to_a
#=> [["http://example.com/foo", [["rel", "self"]]],
#    ["http://example.com/", [["rel", "up"]]]]



