#!/usr/bin/env ruby
require "#{File.dirname(__FILE__)}/helper.rb"

def compare_scrub_methods
  snip = "<div>foo</div><foo>fuxx <b>quux</b></foo><script>i have a chair</script>"
  puts "starting with:\n#{snip}"
  puts
  puts RailsSanitize.new.sanitize(snip) # => Rails.sanitize / scrub!(:prune).to_s
  puts Loofah::Helpers.sanitize(snip)
  puts "--"
  puts RailsSanitize.new.strip_tags(snip) # => Rails.strip_tags / parse().text
  puts Loofah::Helpers.strip_tags(snip)
  puts "--"
  puts Sanitize.clean(snip, Sanitize::Config::RELAXED) # => scrub!(:strip).to_s
  puts Loofah.scrub_fragment(snip, :strip).to_s
  puts "--"
  puts HTML5libSanitize.new.sanitize(snip) # => scrub!(:escape).to_s
  puts Loofah.scrub_fragment(snip, :escape).to_s
  puts "--"
  puts HTMLFilter.new.filter(snip)
  puts Loofah.scrub_fragment(snip, :strip).to_s
  puts
end

module TestSet
  def test_set options={}
    scale = options[:rehearse] ? 10 : 1
    puts self.class.name

    n = 100 / scale
    puts "  Large document, #{BIG_FILE.length} bytes (x#{n})"
    bench BIG_FILE, n, false
    puts

    n = 1000 / scale
    puts "  Small fragment, #{FRAGMENT.length} bytes (x#{n})"
    bench FRAGMENT, n, true
    puts

    n = 10_000 / scale
    puts "  Text snippet, #{SNIPPET.length} bytes (x#{n})"
    bench SNIPPET, n, true
    puts
  end
end

class HeadToHead < Measure
end

class HeadToHeadRailsSanitize < Measure
  include TestSet
  def bench(content, ntimes, fragment_p)
    clear_measure

    measure "Loofah::Helpers.sanitize", ntimes do
      Loofah::Helpers.sanitize content
    end

    sanitizer = RailsSanitize.new
    measure "ActionView sanitize", ntimes do
      sanitizer.sanitize(content)
    end
  end
end

class HeadToHeadRailsStripTags < Measure
  include TestSet
  def bench(content, ntimes, fragment_p)
    clear_measure

    measure "Loofah::Helpers.strip_tags", ntimes do
      Loofah::Helpers.strip_tags content
    end

    sanitizer = RailsSanitize.new
    measure "ActionView strip_tags", ntimes do
      sanitizer.strip_tags(content)
    end
  end
end

class HeadToHeadSanitizerSanitize < Measure
  include TestSet
  def bench(content, ntimes, fragment_p)
    clear_measure

    measure "Loofah :strip", ntimes do
      if fragment_p
        Loofah.scrub_fragment(content, :strip).to_s
      else
        Loofah.scrub_document(content, :strip).to_s
      end
    end

    measure "Sanitize.clean", ntimes do
      Sanitize.clean(content, Sanitize::Config::RELAXED)
    end
  end
end

class HeadToHeadHtml5LibSanitize < Measure
  include TestSet
  def bench(content, ntimes, fragment_p)
    clear_measure

    measure "Loofah :escape", ntimes do
      if fragment_p
        Loofah.scrub_fragment(content, :escape).to_s
      else
        Loofah.scrub_document(content, :escape).to_s
      end
    end

    html5_sanitizer = HTML5libSanitize.new
    measure "HTML5lib.sanitize", ntimes do
      html5_sanitizer.sanitize(content)
    end
  end
end

class HeadToHeadHTMLFilter < Measure
  include TestSet
  def bench(content, ntimes, fragment_p)
    clear_measure

    measure "Loofah::Helpers.sanitize", ntimes do
      Loofah::Helpers.sanitize content
    end

    sanitizer = HTMLFilter.new
    measure "HTMLFilter.filter", ntimes do
      sanitizer.filter(content)
    end
  end
end

puts "Nokogiri version: #{Nokogiri::VERSION_INFO.inspect}"
puts "Loofah version: #{Loofah::VERSION.inspect}"

benches = []
benches << HeadToHeadRailsSanitize.new
benches << HeadToHeadRailsStripTags.new
benches << HeadToHeadSanitizerSanitize.new
benches << HeadToHeadHtml5LibSanitize.new
benches << HeadToHeadHTMLFilter.new
puts "---------- rehearsal ----------"
benches.each { |bench| bench.test_set :rehearse => true }
puts "---------- realsies ----------"
benches.each { |bench| bench.test_set }
