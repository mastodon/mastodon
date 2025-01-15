# frozen_string_literal: true

def gen_border(codepoint, color)
  input = Rails.public_path.join('emoji', "#{codepoint}.svg")
  dest = Rails.public_path.join('emoji', "#{codepoint}_border.svg")
  doc = File.open(input) { |f| Nokogiri::XML(f) }
  svg = doc.at_css('svg')
  if svg.key?('viewBox')
    view_box = svg['viewBox'].split.map(&:to_i)
    view_box[0] -= 2
    view_box[1] -= 2
    view_box[2] += 4
    view_box[3] += 4
    svg['viewBox'] = view_box.join(' ')
  end
  g = doc.create_element('g')
  doc.css('svg > *').each do |elem|
    border_elem = elem.dup

    border_elem.delete('fill')

    border_elem['stroke'] = color
    border_elem['stroke-linejoin'] = 'round'
    border_elem['stroke-width'] = '4px'

    g.add_child(border_elem)
  end
  svg.prepend_child(g)
  File.write(dest, doc.to_xml)
  puts "Wrote bordered #{codepoint}.svg to #{dest}!"
end

def codepoints_to_filename(codepoints)
  codepoints.downcase.gsub(/\A0+/, '').tr(' ', '-')
end

def codepoints_to_unicode(codepoints)
  if codepoints.include?(' ')
    codepoints.split.map(&:hex).pack('U*')
  else
    [codepoints.hex].pack('U')
  end
end

namespace :emojis do
  desc 'Generate a unicode to filename mapping'
  task :generate do
    source = 'http://www.unicode.org/Public/emoji/15.0/emoji-test.txt'
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

    existence_maps = grouped_codes.map { |c| c.index_with { |cc| Rails.public_path.join('emoji', "#{codepoints_to_filename(cc)}.svg").exist? } }
    map = {}

    existence_maps.each do |group|
      existing_one = group.key(true)

      next if existing_one.nil?

      group.each_key do |key|
        map[codepoints_to_unicode(key)] = codepoints_to_filename(existing_one)
      end
    end

    map = map.sort { |a, b| a[0].size <=> b[0].size }.to_h

    File.write(dest, Oj.dump(map))
    puts "Wrote emojo to destination! (#{dest})"
  end

  desc 'Generate emoji variants with white borders'
  task :generate_borders do
    src = Rails.root.join('app', 'javascript', 'mastodon', 'features', 'emoji', 'emoji_map.json')
    emojis_light = '👽⚾🐔☁️💨🕊️👀🍥👻🐐❕❔⛸️🌩️🔊🔇📃🌧️🐏🍚🍙🐓🐑💀☠️🌨️🔉🔈💬💭🏐🏳️⚪⬜◽◻️▫️🪽🪿'
    emojis_dark = '🎱🐜⚫🖤⬛◼️◾◼️✒️▪️💣🎳📷📸♣️🕶️✴️🔌💂‍♀️📽️🍳🦍💂🔪🕳️🕹️🕋🖊️🖋️💂‍♂️🎤🎓🎥🎼♠️🎩🦃📼📹🎮🐃🏴🐞🕺📱📲🚲🪮🐦‍⬛'

    map = Oj.load(File.read(src))

    emojis_light.each_grapheme_cluster do |emoji|
      gen_border map[emoji], 'black'
    end
    emojis_dark.each_grapheme_cluster do |emoji|
      gen_border map[emoji], 'white'
    end
  end

  desc 'Download the JSON sheet data of emojis'
  task :download_sheet_json do
    source = 'https://raw.githubusercontent.com/iamcal/emoji-data/refs/tags/v15.1.2/emoji.json'
    dest   = Rails.root.join('app', 'javascript', 'mastodon', 'features', 'emoji', 'emoji_sheet.json')

    puts "Downloading emoji data from source... (#{source})"

    res = HTTP.get(source).to_s
    data = JSON.parse(res)

    filtered_data = data.map do |emoji|
      filtered_item = {
        'unified' => emoji['unified'],
        'sheet_x' => emoji['sheet_x'],
        'sheet_y' => emoji['sheet_y'],
        'skin_variations' => {},
      }

      emoji['skin_variations']&.each do |key, variation|
        filtered_item['skin_variations'][key] = {
          'unified' => variation['unified'],
          'sheet_x' => variation['sheet_x'],
          'sheet_y' => variation['sheet_y'],
        }
      end

      filtered_item
    end

    File.write(dest, JSON.generate(filtered_data))
  end
end
