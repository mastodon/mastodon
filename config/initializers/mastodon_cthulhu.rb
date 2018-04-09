MastodonCthulhu.setup do |status|	
  	
　# クトゥルフ神話機能	
  fortune = MastodonCommand::Random.new('[ 　\n]?#(クトゥルフ神話)[ 　\n]?', %w(いあいあくとぅるぅ いあいあはすたぁ いあいあつとぅぁぐぁ ふんぐるいむぐるうなふ うがふなぐる ふたぐん))
  status = fortune.convert(status) if fortune.match(status)	

end
