Nyaaaan.setup do |status|
  
    # 社会性フィルター機能
    filter = Nyaaaan::Lang.new('[ 　\n]?#(社会性フィルター)[ 　\n]?', [
      {
        pattern: '死ね',
        replace: 'にゃーん'
      },
  
    ])
    status = filter.convert(status) if filter.match(status)
    status
end
