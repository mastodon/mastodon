namespace :hamlit do
  desc 'Convert erb to haml in app/views'
  task :erb2haml do
    begin
      gem 'html2haml'
    rescue LoadError
      puts "html2haml gem is not part of the bundle."
      puts "`rake hamlit:erb2haml` requires html2haml gem to convert erb files."
      puts
      puts "Please add html2haml gem temporarily and run `rake hamlit:erb2haml` again."
      puts "(You can remove html2haml gem after the conversion.)"
      exit 1
    end

    erb_files = Dir.glob('app/views/**/*.erb').select(&File.method(:file?))
    if erb_files.empty?
      puts 'No .erb files found. Skipping.'
      return
    end

    haml_files_in_erb = Dir.glob('app/views/**/*.haml').select(&File.method(:file?)).map do |name|
      name.sub(/\.haml\z/, '.erb')
    end
    existing_files = erb_files.select(&haml_files_in_erb.method(:include?))

    if existing_files.any?
      puts 'Some of your .erb files seem to have .haml equivalents:'
      existing_files.map { |f| puts "  #{f}" }
      puts

      begin
        print 'Do you want to overwrite them? (y/n): '
        answer = STDIN.gets.strip.downcase[0]
      end until ['y', 'n'].include?(answer)

      if answer == 'n'
        if (erb_files - existing_files).empty?
          puts 'No .erb files to convert. Skipping.'
          return
        end
      else
        existing_files.each { |file| File.delete(file.sub(/\.erb\z/, '.haml')) }
      end
    end
    puts

    erb_files.each do |file|
      puts "Generating .haml for #{file}..."
      unless system("html2haml #{file} #{file.sub(/\.erb\z/, '.haml')}")
        abort "Failed to execute `html2haml #{file} #{file.sub(/\.erb\z/, '.haml')}`!"
      end
    end
    puts

    begin
      print 'Do you want to delete original .erb files? (y/n): '
      answer = STDIN.gets.strip.downcase[0]
    end until ['y', 'n'].include?(answer)

    if answer == 'y'
      puts 'Deleting original .erb files...'
      File.delete(*erb_files)
      erb_files.each { |file| puts "  #{file}" }
    end
    puts

    puts 'Finished to convert erb files.'
  end
end
