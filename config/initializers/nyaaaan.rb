Nyaaaan.setup do |status|
  
    # 社会性フィルター機能
    filter = Nyaaaan::Lang.new('[ 　\n]?[ 　\n]?', [
      {
        pattern: '死ね',
        replace: 'にゃーん'
      },
  
    ])
    status = filter.convert(status) if filter.match(status)
    status
end
