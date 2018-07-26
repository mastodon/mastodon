MastodonCthulhu.setup do |status|   

    　# こゃーん！    
      fortune = Koyaaan::Random.new('[ 　\n]?#(社会性フィルター)[ 　\n]?', %w(こゃーん！))
      status = fortune.convert(status) if fortune.match(status)     
end