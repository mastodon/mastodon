# frozen_string_literal: true

def gen_border(codepoint)
  input = Rails.root.join('public', 'emoji', "#{codepoint}.svg")
  dest = Rails.root.join('public', 'emoji', "#{codepoint}_border.svg")
  doc = File.open(input) { |f| Nokogiri::XML(f) }
  svg = doc.at_css('svg')
  if svg.key?('viewBox')
    view_box = svg['viewBox'].split(' ').map(&:to_i)
    view_box[0] -= 2
    view_box[1] -= 2
    view_box[2] += 4
    view_box[3] += 4
    svg['viewBox'] = view_box.join(' ')
  end
  g = Nokogiri::XML::Node.new 'g', doc
  doc.css('svg > *').each do |elem|
    border_elem = elem.dup

    border_elem.delete('fill')

    border_elem['stroke'] = 'white'
    border_elem['stroke-linejoin'] = 'round'
    border_elem['stroke-width'] = '4px'

    g.add_child(border_elem)
  end
  svg.prepend_child(g)
  svg['style'] = 'background: black;'
  File.write(dest, doc.to_xml)
  puts "Wrote bordered #{codepoint}.svg to #{dest}!"
end

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
    source = 'http://www.unicode.org/Public/emoji/12.0/emoji-test.txt'
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
    codepoints = %w(1f3b1 1f41c 1f519 26ab 1f5a4 2b1b 25fe 25fc 2712 25aa 1f4a3 1f3b3 1f464 1f465 1f4f7 1f4f8 2663 27b0 1f4b1 1f576 2734 1f50c 1f51a 1f482-200d-2640-fe0f 1f482-1f3fb-200d-2640-fe0f 1f482-1f3fc-200d-2640-fe0f 1f482-1f3fd-200d-2640-fe0f 1f482-1f3fe-200d-2640-fe0f 1f482-1f3ff-200d-2640-fe0f 1f4fd 1f373 1f98d 1f482 1f482-1f3fb 1f482-1f3fc 1f482-1f3fd 1f482-1f3fe 1f482-1f3ff 2714 2797 1f4b2 2796 2716 2795 1f52a 1f573 1f579 1f54b 1f58a 1f58b 1f482-200d-2642-fe0f 1f482-1f3fb-200d-2642-fe0f 1f482-1f3fc-200d-2642-fe0f 1f482-1f3fd-200d-2642-fe0f 1f482-1f3fe-200d-2642-fe0f 1f482-1f3ff-200d-2642-fe0f 1f3a4 1f393 1f3a5 1f3bc 1f51b 1f51c 2660 1f5e3 1f577 1f4de 2122 1f51d 1f3a9 1f983 1f4fc 1f4f9 1f3ae 1f403 1f3f4 3030)
    codepoints.each do |cc|
      gen_border cc
    end
  end
end
