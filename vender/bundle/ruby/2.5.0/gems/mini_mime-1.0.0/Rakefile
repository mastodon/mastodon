require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

def pad(array)
  max = []
  array.each do |row|
    i = 0
    row.each do |col|
      max[i] = [max[i] || 0, col.length].max
      i += 1
    end
  end

  array.each do |row|
    i = 0
    row.each do |col|
      col << " " * (max[i] - col.length)
      i += 1
    end
  end

end

desc "generate mime type database"
task :rebuild_db do
  puts "Generating mime type DB"
  require 'mime/types'
  index = {}

  MIME::Types.each do |type|
    type.extensions.each {|ext| (index[ext.downcase] ||= []) << type}
  end

  index.each do |k,list|
    list.sort!{|a,b| a.priority_compare(b)}
  end

  buffer = []

  index.each do |ext, list|
    mime_type = list.detect { |t| !t.obsolete? }
    mime_type ||= list.detect(&:registered)
    mime_type ||= list.first
    buffer << [ext.dup, mime_type.content_type.dup, mime_type.encoding.dup]
  end

  pad(buffer)

  buffer.sort!{|a,b| a[0] <=> b[0]}

  File.open("lib/db/ext_mime.db", File::CREAT|File::TRUNC|File::RDWR) do |f|
    buffer.each do |row|
      f.write "#{row[0]} #{row[1]} #{row[2]}\n"
    end
  end

  puts "#{buffer.count} rows written to lib/db/ext_mime.db"

  buffer.sort!{|a,b| [a[1], a[0]] <=> [b[1], b[0]]}

  # strip cause we are going to re-pad
  buffer.each do |row|
    row.each do |col|
      col.strip!
    end
  end

  # we got to confirm we pick the right extension for each type
  buffer.each do |row|
    row[0] = MIME::Types.type_for("xyz.#{row[0].strip}")[0].extensions[0].dup
  end

  pad(buffer)

  File.open("lib/db/content_type_mime.db", File::CREAT|File::TRUNC|File::RDWR) do |f|
    last = nil
    count = 0
    buffer.each do |row|
      unless last == row[1]
        f.write "#{row[0]} #{row[1]} #{row[2]}\n"
        count += 1
      end
      last = row[1]
    end
    puts "#{count} rows written to lib/db/content_type_mime.db"
  end

end
