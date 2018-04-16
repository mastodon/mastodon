module FileHelpers
  def append_to(path, contents)
    cd(".") do
      File.open(path, "a") do |file|
        file.puts
        file.puts contents
      end
    end
  end

  def append_to_gemfile(contents)
    append_to('Gemfile', contents)
  end

  def comment_out_gem_in_gemfile(gemname)
    cd(".") do
      gemfile = File.read("Gemfile")
      gemfile.sub!(/^(\s*)(gem\s*['"]#{gemname})/, "\\1# \\2")
      File.open("Gemfile", 'w'){ |file| file.write(gemfile) }
    end
  end

  def read_from_web(url)
    file = if url.match %r{^https?://}
             Net::HTTP.get(URI.parse(url))
           else
             visit(url)
             page.source
           end
    file.force_encoding("UTF-8") if file.respond_to?(:force_encoding)
  end
end

World(FileHelpers)
