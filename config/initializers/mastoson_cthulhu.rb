MastodonCthulhu.setup do |status|	
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(クトゥルフ神話)[ 　\n]?', %w(いあ!いあ!くとぅるぅ! いあ!いあ!はすたぁ! いあ!いあ!つとぅぁぐぁ! ふんぐるいむぐるうなふ! うがふなぐる! ふたぐん! ふんぐるい！むぐるうなふ！くとぅぐあ！ふぉまるはうと！んがあ・ぐあ！なふるたぐん！いあ！くとぅぐあ！ いあ！いあ！はすたあ！はすたあ!くふあやく!ぶるぐとむ!ぶぐとらぐるん!ぶるぐとむ!あい！あい！はすたあ！))
  status = fortune.convert(status) if fortune.match(status)	
  status

  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(スーモ)[ 　\n]?', %w(あ❗️スーモ❗️🌚ダン💥ダン💥ダン💥シャーン🎶スモ🌝スモ🌚スモ🌝スモ🌚スモ🌝スモ🌚ス〜〜〜モ⤴スモ🌚スモ🌝スモ🌚スモ🌝スモ🌚スモ🌝ス～～～モ⤵🌞))
  status = fortune.convert(status) if fortune.match(status)	
  status

  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(社会性フィルター)[ 　\n]?', %w(こゃーん！))
  status = status.replace("こゃーん！ :neko_oinari: \n #社会性フィルター") if fortune.match(status)	
  status
  
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(wandbox)[ 　\n]?', %w(こゃーん！))
  if fortune.match(status) then
    status.gsub!(/#wandbox/, '')
    File.open("./config/initializers/wandbox.cpp", "w+") do |file|
      file.write status
    end
    
    s = Open3.capture3("wandbox run ./config/initializers/wandbox.cpp --compiler=clang-head")
    puts s
    if s[0].length == 0 then
      status = status.replace("[Wandbox]三へ( へ՞ਊ ՞)へ ﾊｯﾊｯ\n\n\n #{s} \n #wandbox")
    elsif s[0].length <= 500 then
      status = status.replace("[Wandbox]三へ( へ՞ਊ ՞)へ ﾊｯﾊｯ\n\n\n #{s[0]} \n #wandbox")
    else
      status = status.replace("[Wandbox]三へ( へ՞ਊ ՞)へ ﾊｯﾊｯ\n\n\n 文字数がオーバーしています \n #wandbox")
    end
  end
  
  cthulhu = Cthulhu.find(rand(Cthulhu.count) + 1).story
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(Cthulhu)[ 　\n]?', %W(#{cthulhu}))
  status = fortune.convert(status) if fortune.match(status)	
  status
end
