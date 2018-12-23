# frozen_string_literal: true

def codepoints_to_filename(codepoints)
  codepoints.downcase.gsub(/\A[0]+/, '').tr(' ', '-')
end

def codepoints_to_unicode(codepoints)
  if codepoints.include?(' ')
    codepoints.split(' ').map(&:hex).pack('U*')
  else
    [codepoints.hex].pack('U')
  end
end

namespace :emojis do
  desc 'Generate a unicode to filename mapping'
  task :generate do
    source = 'http://www.unicode.org/Public/emoji/5.0/emoji-test.txt'
    codes  = []
    dest   = Rails.root.join('app', 'javascript', 'mastodon', 'features', 'emoji', 'emoji_map.json')

    puts "Downloading emojos from source... (#{source})"

    HTTP.get(source).to_s.split("\n").each do |line|
      next if line.start_with? '#'
      parts = line.split(';').map(&:strip)
      next if parts.size < 2
      codes << [parts[0], parts[1].start_with?('fully-qualified')]
    end

    grouped_codes = codes.reduce([]) do |agg, current|
      if current[1]
        agg << [current[0]]
      else
        agg.last << current[0]
        agg
      end
    end

    existence_maps = grouped_codes.map { |c| c.map { |cc| [cc, File.exist?(Rails.root.join('public', 'emoji', codepoints_to_filename(cc) + '.svg'))] }.to_h }
    map = {}

    existence_maps.each do |group|
      existing_one = group.key(true)

      group.each_key do |key|
        map[codepoints_to_unicode(key)] = codepoints_to_filename(existing_one)
      end
    end

    map = map.sort { |a, b| a[0].size <=> b[0].size }.to_h

    File.write(dest, Oj.dump(map))
    puts "Wrote emojo to destination! (#{dest})"
  end
end
