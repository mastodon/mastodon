MastodonCthulhu.setup do |status|	
  	
　# クトゥルフ神話
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(クトゥルフ神話)[ 　\n]?', %w(いあいあくとぅるぅ いあいあはすたぁ いあいあつとぅぁぐぁ ふんぐるいむぐるうなふ うがふなぐる ふたぐん))
  status = fortune.convert(status) if fortune.match(status)	

  status
end
