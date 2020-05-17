# frozen_string_literal: true

def gen_border(codepoint)
  input = Rails.root.join('public', 'emoji', "#{codepoint}.svg")
  dest = Rails.root.join('public', 'emoji', "#{codepoint}_border.svg")
  doc = File.open(input) { |f| Nokogiri::XML(f) }
  svg = doc.at_css("svg")
  if svg.key?("viewBox")
    viewBox = svg["viewBox"].split(" ").map { |s| s.to_i }
    viewBox[0] -= 2
    viewBox[1] -= 2
    viewBox[2] += 4
    viewBox[3] += 4
    svg["viewBox"] = viewBox.join(" ")
  end
  g = Nokogiri::XML::Node.new "g", doc
  for elem in doc.css("svg > *")
    border_elem = elem.dup

    if border_elem.key?("fill")
      border_elem.delete("fill")
    end
    border_elem["stroke"] = "white"

    style = ""
    if border_elem.key?("style")
      style = border_elem["style"]
    end
    old_width = "0px"
    if border_elem.key?("stroke-width")
      old_width = border_elem["stroke-width"]
    end
    style += " stroke-width: calc(#{old_width} + 4px)"
    border_elem["style"] = style.strip

    g.add_child(border_elem)
  end
  svg.prepend_child(g)
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
  task :generate_borders, [] do |task, args|
    for cc in args.extras
      gen_border cc
    end
  end
end
