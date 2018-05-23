require "redis"
require "redis/distributed"

r = Redis::Distributed.new %w[redis://localhost:6379 redis://localhost:6380 redis://localhost:6381 redis://localhost:6382]

r.flushdb

r['urmom'] = 'urmom'
r['urdad'] = 'urdad'
r['urmom1'] = 'urmom1'
r['urdad1'] = 'urdad1'
r['urmom2'] = 'urmom2'
r['urdad2'] = 'urdad2'
r['urmom3'] = 'urmom3'
r['urdad3'] = 'urdad3'
p r['urmom']
p r['urdad']
p r['urmom1']
p r['urdad1']
p r['urmom2']
p r['urdad2']
p r['urmom3']
p r['urdad3']

r.rpush 'listor', 'foo1'
r.rpush 'listor', 'foo2'
r.rpush 'listor', 'foo3'
r.rpush 'listor', 'foo4'
r.rpush 'listor', 'foo5'

p r.rpop('listor')
p r.rpop('listor')
p r.rpop('listor')
p r.rpop('listor')
p r.rpop('listor')

puts "key distribution:"

r.ring.nodes.each do |node|
  p [node.client, node.keys("*")]
end
r.flushdb
p r.keys('*')
