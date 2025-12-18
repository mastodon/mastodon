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

def get_image(row, emoji_base, fallback, compressed)
  path = emoji_base.join("#{row[compressed ? 'b' : 'unified'].downcase}.svg")
  path = emoji_base.join("#{row[compressed ? 'c' : 'non_qualified'].downcase.sub(/^00/, '')}.svg") if !path.exist? && row[compressed ? 'c' : 'non_qualified']
  if path.exist?
    Vips::Image.new_from_file(path.to_s, dpi: 64)
  else
    puts "Missing emoji: #{row['b'] || row['unified']}"
    fallback
  end
end

def titleize(string)
  string.humanize.gsub(/\b(?<!['’`()])(?!(and|the|or|with|a)\b)[a-z]/, &:capitalize)
end

namespace :emojis do
  desc 'Generate a unicode to filename mapping'
  task :generate do
    source = 'https://www.unicode.org/Public/emoji/16.0/emoji-test.txt'
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

  desc 'Generate the JSON emoji data'
  task :generate_json do
    data_source = 'https://raw.githubusercontent.com/iamcal/emoji-data/refs/tags/v16.0.0/emoji.json'
    keyword_source = 'https://raw.githubusercontent.com/muan/emojilib/refs/tags/v3.0.12/dist/emoji-en-US.json'
    data_dest = Rails.root.join('app', 'javascript', 'mastodon', 'features', 'emoji', 'emoji_data.json')

    puts "Downloading emoji data from source... (#{data_source})"
    res = HTTP.get(data_source).to_s
    data = JSON.parse(res)

    puts "Downloading keyword data from source... (#{keyword_source})"
    res = HTTP.get(keyword_source).to_s
    keywords = JSON.parse(res)

    puts 'Generating JSON emoji data...'

    emoji_data = {
      compressed: true,
      categories: [
        { id: 'smileys', name: 'Smileys & Emotion', emojis: [] },
        { id: 'people', name: 'People & Body', emojis: [] },
        { id: 'nature', name: 'Animals & Nature', emojis: [] },
        { id: 'foods', name: 'Food & Drink', emojis: [] },
        { id: 'activity', name: 'Activities', emojis: [] },
        { id: 'places', name: 'Travel & Places', emojis: [] },
        { id: 'objects', name: 'Objects', emojis: [] },
        { id: 'symbols', name: 'Symbols', emojis: [] },
        { id: 'flags', name: 'Flags', emojis: [] },
      ],
      emojis: {},
      aliases: {},
    }

    sorted = data.sort { |a, b| (a['sort_order'] || a['short_name']) - (b['sort_order'] || b['sort_name']) }
    category_map = emoji_data[:categories].each_with_index.to_h { |c, i| [c[:name], i] }

    sorted.each do |emoji|
      emoji_keywords = keywords[codepoints_to_unicode(emoji['unified'].downcase)]

      single_emoji = {
        a: titleize(emoji['name']), # name
        b: emoji['unified'], # unified
        f: true, # has_img_twitter
        k: [emoji['sheet_x'], emoji['sheet_y']], # sheet
      }

      single_emoji[:c] = emoji['non_qualified'] unless emoji['non_qualified'].nil? # non_qualified
      single_emoji[:j] = emoji_keywords.filter { |k| k != emoji['short_name'] } if emoji_keywords.present? # keywords
      single_emoji[:l] = emoji['texts'] if emoji['texts'].present? # emoticons
      single_emoji[:m] = emoji['text'] if emoji['text'].present? # text
      single_emoji[:skin_variations] = emoji['skin_variations'] if emoji['skin_variations'].present?

      emoji_data[:emojis][emoji['short_name']] = single_emoji
      emoji_data[:categories][category_map[emoji['category']]][:emojis].push(emoji['short_name']) if emoji['category'] != 'Component'

      emoji['short_names'].each do |name|
        emoji_data[:aliases][name] = emoji['short_name'] unless name == emoji['short_name']
      end
    end

    smileys = emoji_data[:categories][0]
    people = emoji_data[:categories][1]
    smileys_and_people = { id: 'people', name: 'Smileys & People', emojis: [*smileys[:emojis][..128], *people[:emojis], *smileys[:emojis][129..]] }
    emoji_data[:categories].unshift(smileys_and_people)
    emoji_data[:categories] -= emoji_data[:categories][1, 2]

    File.write(data_dest, JSON.generate(emoji_data))
  end

  desc 'Generate a spritesheet of emojis'
  task :generate_emoji_sheet do
    require 'vips'

    src = Rails.root.join('app', 'javascript', 'mastodon', 'features', 'emoji', 'emoji_data.json')
    sheet = Oj.load(File.read(src))

    max = 0
    sheet['emojis'].each_value do |row|
      max = [max, row['k'][0], row['k'][1]].max
      next if row['skin_variations'].blank?

      row['skin_variations'].each_value do |variation|
        max = [max, variation['sheet_x'], variation['sheet_y']].max
      end
    end

    size = max + 1

    puts 'Generating spritesheet...'

    emoji_base = Rails.public_path.join('emoji')
    fallback = Vips::Image.new_from_file(emoji_base.join('2753.svg').to_s, dpi: 64)
    comp = Array.new(size) do
      Array.new(size, 0)
    end

    sheet['emojis'].each_value do |row|
      comp[row['k'][1]][row['k'][0]] = get_image(row, emoji_base, fallback, true)
      next if row['skin_variations'].blank?

      row['skin_variations'].each_value do |variation|
        comp[variation['sheet_y']][variation['sheet_x']] = get_image(variation, emoji_base, fallback, false)
      end
    end

    joined = Vips::Image.arrayjoin(comp.flatten, across: size, hspacing: 34, halign: :centre, vspacing: 34, valign: :centre)
    joined.write_to_file(emoji_base.join('sheet_16_0.png').to_s, palette: true, dither: 0, Q: 100)
  end
end
