Nyaaaan.setup do |status|	
  	
    # 社会性フィルター機能	
    nyaaaan = Nyaaaan::Lang.new('[ 　\n]?#(社会性フィルター)[ 　\n]?', [	
      {	
        pattern: '死',	
        replace: 'にゃーん'	
      },	
      
      {	
        pattern: 'くたばれ',	
        replace: 'にゃーん'	
      },	
      
      {	
        pattern: 'アスペ',	
        replace: 'にゃーん'	
      },	
      
      {	
        pattern: 'ガイジ',	
        replace: 'にゃーん'	
      },
      
      {	
        pattern: 'キチガイ',	
        replace: 'にゃーん'	
      },
      
      {
        pattern: '殺',
        replace: 'にゃーん'
      },
    ])	
    status = nyaaaan.convert(status) if nyaaaan.match(status)	
    status	
end
