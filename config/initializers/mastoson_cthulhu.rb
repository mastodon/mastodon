MastodonCthulhu.setup do |status|	
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(クトゥルフ神話)[ 　\n]?', %w(いあ!いあ!くとぅるぅ! いあ!いあ!はすたぁ! いあ!いあ!つとぅぁぐぁ! ふんぐるいむぐるうなふ! うがふなぐる! ふたぐん! ふんぐるい！むぐるうなふ！くとぅぐあ！ふぉまるはうと！んがあ・ぐあ！なふるたぐん！いあ！くとぅぐあ！ いあ！いあ！はすたあ！はすたあ!くふあやく!ぶるぐとむ!ぶぐとらぐるん!ぶるぐとむ!あい！あい！はすたあ！))
  status = fortune.convert(status) if fortune.match(status)	
  status

  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(スーモ)[ 　\n]?', %w(あ❗️スーモ❗️🌚ダン💥ダン💥ダン💥シャーン🎶スモ🌝スモ🌚スモ🌝スモ🌚スモ🌝スモ🌚ス〜〜〜モ⤴スモ🌚スモ🌝スモ🌚スモ🌝スモ🌚スモ🌝ス～～～モ⤵🌞))
  status = fortune.convert(status) if fortune.match(status)	
  status
end
