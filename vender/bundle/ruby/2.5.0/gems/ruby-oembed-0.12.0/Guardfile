guard "bundler" do
  watch("Gemfile")
end

group :red_green_refactor, :halt_on_fail => true do
  guard "rspec", :cmd => "bundle exec rspec" do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^spec/cassettes/.+.yml$}) { "spec" }
    watch(%r{^lib/(.+)\.rb$}) do |m|
      # Split up the file path into an Array
      path_parts = []
      remaining_path = m[1]
      while File.dirname(remaining_path) != '.'
        remaining_path, file = File.split(remaining_path)
        path_parts << file
      end
      path_parts << remaining_path
      path_parts.reverse!

      # Specs don't contain an oembed subdir
      path_parts.shift
      # Special case for formatter specs
      if path_parts.include?('formatter') && path_parts.include?('backends')
        path_parts.delete('backends')
        path_parts.last.gsub!(/$/, "_backend")
      end
      # Add on the _spec.rb postfix
      path_parts.last.gsub!(/$/, "_spec.rb")

      f = File.join("spec", *path_parts)
      puts "#{m.inspect} => #{f.inspect}"
      f
    end
  end
end
